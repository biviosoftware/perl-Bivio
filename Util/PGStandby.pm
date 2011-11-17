# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::PGStandby;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
b_use('IO.Trace');
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_D) =  b_use('Bivio.Die');
my($_F) = b_use('IO.File');
my($_SC) = b_use('SQL.Connection');

$_C->register(my $_CFG = {
    pg_user => 'postgres',
    pg_group => 'postgres',
    pg_standby => '/usr/lib/postgresql/8.4/bin/pg_standby',
    pg_start => '/etc/init.d/postgresql-8.4 start',
    pg_stop => '/etc/init.d/postgresql-8.4 stop',
    database => 'postgres',
});


sub USAGE {
    return <<'EOF';
usage: b-pgstandby [options] command [args...]
commands:
    live_copy_primary_to_recovery -- run on 'live' machine to make fuzzy snapshot to 'failover' machine
    failover_copy_recovery_to_standby -- run on 'failover' machine to refresh the standby
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub failover_copy_recovery_to_standby {
    my($self) = @_;
    my($recovery_directory, $standby_directory) = _get_running_clusters($self);
    $self->piped_exec($_CFG->{pg_stop});
    $_F->rm_children($standby_directory);
    my($copied) = $self->piped_exec('cp -rpv ' .  $recovery_directory . '/* ' . $standby_directory);
    _trace($$copied) if $_TRACE;
    my($trigger_file_name) = $_F->temp_file;
    _write_recovery_conf($self, {
	data_directory => $standby_directory,
	archive_directory =>  $standby_directory . '/archive',
        trigger_file_name => $trigger_file_name,
    });
    _chown_to_postgres($_F->write($trigger_file_name, "smart\n"));
    $self->piped_exec($_CFG->{pg_start});    
    return;
}

sub live_copy_primary_to_recovery {
    my($self) = @_;
    my($settings) = _get_primary_settings($self);
    b_die('recovery may be running on ', $settings->{failover_host},
	  '. You need to stop postgreSQL there before issuing this command')
	if _is_remote_pg_running($self, $settings->{failover_host}, $settings->{data_directory}, 1);
    _write_recovery_conf($self, {
	name => 'recovery.conf.tmp',
	data_directory => $settings->{data_directory},
	archive_directory => $settings->{archive_directory},
    });
    _chown_to_postgres($_F->mkdir_p($settings->{data_directory} . '/archive'));
    _execute_statement($self, q{select pg_stop_backup()}, undef, 1);
    _execute_statement($self, qq{select pg_start_backup('$settings->{failover_host}')});
    my($dst) =  "$settings->{failover_host}:$settings->{recovery_directory}";
    b_info('Copying ',  $settings->{data_directory}, ' to ' , $dst);
    my($copied) = $self->piped_exec(['rsync',
				     '-avzlSr',
				     '--delete',
				     $settings->{data_directory} . '/.',
				     $dst]);
    _trace($$copied) if $_TRACE;
    my($copied) = $self->piped_exec(['rsync',
				     '-avz',
				     $settings->{data_directory} . '/recovery.conf.tmp',
				     $dst . '/recovery.conf']);
    _trace($$copied) if $_TRACE;
    _execute_statement($self, q{select pg_stop_backup()});
    return;
}

sub _chown_to_postgres {
    my($filename) = @_;
    $_F->chown_by_name($_CFG->{'pg_user'}, $_CFG->{pg_group}, $filename);
    return $filename;
}

sub _execute_statement {
    my($self,  $statement, $params, $ignore_errors) = @_;
    my($connection) = _get_connection($self);
    my($res);
    my($err) = $_D->catch_quietly(
	sub {
	    $res  = $connection->execute($statement, $params);
	    return;
	});
    b_die($err)
	if $err && !$ignore_errors;
    return $res;
}

sub _get_connection {
    my($self) = @_;
    my($config_name) = 'PGStandby';
    $_C->introduce_values({
        'Bivio::Ext::DBI' => {
	    $config_name => {
		connection => 'Bivio::SQL::Connection::Postgres',		
		database => $_CFG->{database},
		user => $_CFG->{pg_user},
	    },
	},
    });
    return $_SC->get_instance($config_name);
}

sub _get_primary_settings {
    my($self) = @_;
    my($settings) = _get_connection($self)->get_settings;
    b_die('archive mode is not enabled')
	unless $settings->{archive_mode} eq 'on';
    b_die('archive timeout is zero')
	unless $settings->{archive_timeout} > 0;
    ($settings->{failover_host}, $settings->{archive_directory}) =
	$settings->{archive_command} =~qr{rsync\s+[^%]*%p\s+(?:[^@]*@)?([^:]+):(/.*)/%f};
    b_die('archive command set to ', $settings->{archive_command},
	'expected "rsync %p name@host:/dir/%f"')
       unless  $settings->{archive_directory};
    $settings->{recovery_directory} = $settings->{data_directory};
    $settings->{recovery_directory} =~ s/\/[^\/]+$/\/recovery/;
    b_die('expected archive directory to be called "archive" under ',
	  $settings->{recovery_directory}, ' not ', $settings->{archive_directory})
	unless $settings->{archive_directory} =~ qr{^$settings->{recovery_directory}/+archive$};
    return $settings;    
}    

sub _get_running_clusters {
    my($self) = @_;
    my(@clusters) = map(/postgres\s+-D\s*(\S+)\s+/,
			split("\n", ${$self->piped_exec(['ps',  '-d',  '-ww',  '-f'])}));
    b_die('postgres not running')
	unless @clusters;
    b_die('no "recovery" cluster found in ', @clusters)
	unless grep(qr{/recovery$}, @clusters);
    b_die('expected only standby and recovery clusters to be running, not ', @clusters)
	if @clusters > 2;
    @clusters = reverse(@clusters)
	unless $clusters[0] =~ qr{/recovery$};
    _trace($clusters[0], ' ', $clusters[1]) if $_TRACE;
    return @clusters;
}

sub _is_remote_pg_running {
    my($self, $host, $data_directory) = @_;
    my($pid_file) = $data_directory . '/postmaster.pid';
    my($out) = $self->piped_exec(['ssh', $host, 'test', '-f', $pid_file, '&&', 'echo', 'exists'], undef, 1);
    return ($$out =~ /exists/) ? 1 : 0;
}

sub _write_recovery_conf {
    my($self, $params) = @_;
    my($rc_name) = $params->{data_directory}
	. '/'
	. ($params->{name} || 'recovery.conf');
    my($contents) = "restore_command='$_CFG->{pg_standby}";
    $contents .= " -t $params->{trigger_file_name}"
	if $params->{trigger_file_name};
    $contents .= " $params->{archive_directory} %f %p %r'\n";
    $contents .= "recovery_end_command = 'rm -f $params->{trigger_file_name}'"
	if $params->{trigger_file_name};
    _chown_to_postgres($_F->write($rc_name, $contents));
    return;    
}

1;
