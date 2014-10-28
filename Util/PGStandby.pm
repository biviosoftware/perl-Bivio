# Copyright (c) 2011-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::PGStandby;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
b_use('IO.Trace');
our($_TRACE);
my($_C) = b_use('IO.Config');
my($_D) =  b_use('Bivio.Die');
my($_F) = b_use('IO.File');
my($_SC) = b_use('SQL.Connection');
my($_SA) = b_use('Type.StringArray');
$_C->register(my $_CFG = {
    pg_user => 'postgres',
    pg_group => 'postgres',
    pg_standby => '/usr/lib/postgresql/8.4/bin/pg_standby',
    pg_recovery_status => '/etc/init.d/pg_recovery status',
    pg_start => ['/etc/init.d/postgresql-8.4', 'start'],
    pg_stop => ['/etc/init.d/postgresql-8.4', 'stop'],
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
    my($recovery_directory, $standby_directory) = _assert_running_clusters($self);
    $self->piped_exec($_CFG->{pg_stop});
    $_F->rm_children($standby_directory);
    my($copied) = $self->piped_exec(
	[
	    'cp',
	    '--archive',
	    $_TRACE ? '--verbose' : (),
	    glob("$recovery_directory/*"),
	    $standby_directory,
	],
    );
    _trace($$copied) if $_TRACE;
    my($trigger_file_name) = $_F->temp_file;
    _write_recovery_conf(
	$self,
	{
	    data_directory => $standby_directory,
	    archive_directory =>  "$standby_directory/archive",
	    trigger_file_name => $trigger_file_name,
	},
    );
    _chown_to_postgres($_F->write($trigger_file_name, "smart\n"));
    $self->piped_exec($_CFG->{pg_start});
    return;
}

sub live_conf {
    my($self) = @_;
    my($settings) = _get_postgresql_conf($self);
    $settings->{config_file};
    return;
}

sub live_copy_primary_to_recovery {
    my($self) = @_;
    my($settings) = _assert_primary_settings($self);
    _assert_recovery_stopped($self, $settings->{failover_host});
    _write_recovery_conf(
	$self,
	{
	    name => 'recovery.conf.tmp',
	    data_directory => $settings->{data_directory},
	    archive_directory => $settings->{archive_directory},
	},
    );
    _chown_to_postgres($_F->mkdir_p("$settings->{data_directory}/archive"));
    _execute_statement($self, q{select pg_stop_backup()}, undef, 1);
    _execute_statement($self, qq{select pg_start_backup('$settings->{failover_host}')});
    my($dst) =  "$settings->{failover_host}:$settings->{recovery_directory}";
    b_info('Copying ',  $settings->{data_directory}, ' to ' , $dst);
    my($copied) = $self->piped_exec([
	'rsync',
	 $_TRACE ? '--verbose' : (),
	'--archive',
	'--compress',
	'--links',
	'--sparse',
	'--delete',
	'--exclude=pg_xlog/',
	"$settings->{data_directory}/",
	$dst,
    ]);
    _trace($$copied) if $_TRACE;
    $copied = $self->piped_exec([
	'rsync',
	 $_TRACE ? '--verbose' : (),
	'--archive',
	'--compress',
	"$settings->{data_directory}/recovery.conf.tmp",
	$dst . '/recovery.conf',
    ]);
    _trace($$copied) if $_TRACE;
    _execute_statement($self, q{select pg_stop_backup()});
    return;
}

sub _assert_primary_settings {
    my($settings) = _get_postgresql_conf(@_);
    b_die("archive mode is not enabled; run $0 live_conf")
	unless $settings->{archive_mode} eq 'on';
    b_die('archive timeout is zero')
	unless $settings->{archive_timeout} > 0;
    ($settings->{failover_host}, $settings->{archive_directory}) =
	$settings->{archive_command} =~qr{rsync\s+[^%]*%p\s+(?:[^@]*@)?([^:]+):(/.*)/%f};
    b_die('archive command set to ', $settings->{archive_command},
	'expected "rsync %p name@host:/dir/%f"')
       unless  $settings->{archive_directory};
    $settings->{recovery_directory} = $settings->{data_directory};
#TODO: Generalize
    $settings->{recovery_directory} =~ s{pgsql}{pg_recovery};
    b_die('expected archive directory to be called "archive" under ',
	  $settings->{recovery_directory}, ' not ', $settings->{archive_directory})
	unless $settings->{archive_directory} =~ qr{^$settings->{recovery_directory}/+archive$};
    return $settings;
}

sub _assert_recovery_stopped {
    my($self, $host) = @_;
    return ${$self->piped_exec_remote(
	$host,
	$_CFG->{pg_recovery_status},
	undef,
	1,
    )} =~ /stopped/ ? 1 : 0;
}

sub _assert_running_clusters {
    my($self) = @_;
    my($clusters) = $_SA->sort_unique([
	$self->do_backticks([qw(ps -C postmaster --format cmd -ww)])
	    =~ m{\s-D\s+(/\S+)}g,
    ]);
    b_die('postgres not running')
	unless @$clusters;
    b_die('no "recovery" cluster found in ', $clusters)
	unless grep(m{/recovery$}, @$clusters);
    b_die('expected only standby and recovery clusters to be running, not ', $clusters)
	if @$clusters > 2;
    _trace($clusters) if $_TRACE;
    return $clusters->[0] =~ qr{/recovery$} ? @$clusters : reverse(@$clusters);
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
    return $_SC->get_instance('dbms');
}

sub _get_postgresql_conf {
    my($self) = @_;
    return _get_connection($self)->get_settings;
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
