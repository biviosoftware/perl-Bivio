# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
#
# Use PostgreQL's WAL archive to create a warm standby.
#
# Primary DB has to be configured with:
#     archive_mode = true
#     archive_command = cp %p archive-location/%f
#     archive_timeout = value greater than zero
#
# Standby needs to know the primary's host name, port, PG user etc in the
# 'pg_instances' config.
#
# On the standby:
#
#   b-pgstandby initialize_standby primary-inst-name
#
# This stops postgreSQL, snapshots the DB cluster from the primary
# and then starts PG in standby mode fetching the WAL data from
# the primary with rsync. PG then applies the WAL to the standby DB
# cluster.
#
# To make the standby DB become accessible i.e. become primary:
#
#     b-pgstandby takeover_from_primary
#
package Bivio::Util::PGStandby;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
b_use('Bivio::IO::Trace');
use Sys::Hostname;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_A) = b_use('IO.Alert');
my($_F) = b_use('IO.File');
Bivio::IO::Config->register(my $_CFG = {
    pg_instances => {
	_defaults => {
	    port => 5432,
	    dbname => 'postgres',
	    username => 'postgres',
	    password => 'postgres',
	},	
    },
    pg_user => 'postgres',
    pg_group => 'postgres',
    pg_standby => '/usr/lib/postgresql/8.4/bin/pg_standby',    
    pg_start => '/etc/init.d/postgresql-8.4 start',
    pg_stop => '/etc/init.d/postgresql-8.4 stop',
    trigger_file_name => '/tmp/pgsql.trigger',
});

sub USAGE {
    return <<'EOF';
usage: b-pgstandby [options] command [args...]
commands:
    initialize_standby [primary-inst-name] -- copy DB from primary and start PG in standby mode
    show_primary [primary-inst-name] -- check configuration and status of primary system
    show_instances [inst-name-regexp] -- display configured PG 'instances' (aka 'clusters')
    pg_apply_wal -- called by postgreSQL, not intended for interactive use
    takeover_from_primary -- recover DBs and become primary
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub initialize_standby {
    my($self, $inst_name) = @_;
    _assert_config($self, [qw(pg_standby pg_start pg_stop)]);
    my($inst) = _get_inst($self, $inst_name);
    my($archive_dir, $data_dir, $timeout) = _get_primary_info($self, $inst);
    # stop any backup that may be in progress
    _execute_statement($self, q{select pg_stop_backup()}, $inst, 1);
    # indicate to primary that we shall make a backup
    my($host) = hostname();
    my($start) = _execute_statement($self, qq{select pg_start_backup('pgstandby-$host')}, $inst);
    # stop local PG
    $self->piped_exec($_CFG->{pg_stop}, undef, 1);
    # clean up old state
    $_F->rm_rf($archive_dir . '/*');
    $_F->rm_rf($data_dir . '/*');
    # fuzzy file snapshot of primary's DB
    $self->piped_exec('rsync -avzlSr --delete '
			  . $inst->{host} . ':'
			  . $data_dir. '/* ' . $data_dir);
    # tell primary we have finished the backup
    my($finish) = _execute_statement($self, q{select pg_stop_backup()}, $inst);
    # write the recovery configuration - makes PG start in recovery mode
    my($rc_name) = $data_dir . '/recovery.conf';
    my($restore_command) = 'bivio PGStandby pg_apply_wal '
	. $_CFG->{pg_standby} . ' '
	. $inst->{host} . ' '
	. $timeout . ' '
	. $_CFG->{trigger_file_name} .  ' '
	. $archive_dir 
	. ' %f %p %r'; 
    $_F->write($rc_name, << "END");
restore_command='$restore_command'
recovery_end_command = 'rm -f $_CFG->{trigger_file_name}'
END
    # Remove trigger file just in case
    unlink($_CFG->{trigger_file_name});
 
    # start local PG in recovery mode
    $self->piped_exec($_CFG->{pg_start});
    return;
}

#
# This method is called by postgreSQL to apply the WAL on the standby.
# Normally postgreSQL would be configured to just call pg_standby
# to do the work. Here we fetch the WAL files from the primary before
# calling pg_standby. Because we have fetched the required file and
# already checked the trigger file, pg_standby should never have to
# wait. All the required configuration is passed on the command line.
#
sub pg_apply_wal {
    my($self, $pg_standby, $primary_host, $timeout, $trigger, $archive_dir, $f, $p, $r) = @_;
    my($wal) = $archive_dir . '/' . $f;
    # I have never seen a .history file though they are sometimes asked for
    # pg_standby source code says don't wait for them
    until ($f =~ /\.history$/ || -e $trigger || -e $wal) {
    	b_info("waiting $timeout seconds for $trigger or $wal");
    	sleep($timeout);
	# move the wal files, ignore errors because they would cause the standby to become active
	# but we want takeover to be manual. Also rsync considers an empty source to be an error.
    	b_info(${$self->piped_exec('rsync -avzlS --delete  --remove-source-files '
				     . $primary_host . ':' . $archive_dir . '/* '
				     . $archive_dir, undef, 1)});
    }
    # pg_standby's "-d" option generates more output. The "-s" option is irrelevant 
    # because pg_standby should never have to wait.
    my($rc) =  system("$pg_standby  -s 2 -t $trigger $archive_dir $f $p $r");
    # return pg_standby exit code transparently to pg
    exit($rc);
    return;
}

sub show_instances {
    my($self, $supplied_name) = @_;
    foreach my $inst_name (sort(keys(%{$_CFG->{pg_instances}}))) {
	next if $supplied_name && $inst_name !~ qr{^$supplied_name$};
    }
    return;
}

sub show_primary {
    my($self, $inst_name) = @_;
    my($inst) = _get_inst($self, $inst_name);
    my($archive_dir, $data_dir, $timeout) = _get_primary_info($self, $inst);
    _println($inst);
    _println('archive_dir=', $archive_dir);
    _println('data_dir=', $data_dir);
    _println('timeout=', $timeout);
    return;
}

sub takeover_from_primary {
    my($self, $inst_name) = @_;
    my($tfn) =  $_CFG->{trigger_file_name};
    my($dtfn) =  $tfn . '_disabled';
    die('Trigger file already exists: ', $tfn) if -e $tfn;
    $_F->write($tfn, "smart\n");
    $_F->chmod(0777, $tfn);   
    return;
}

sub _assert_config {
    my($self, $mandatories) = @_;
    foreach my $mandatory (@$mandatories) {
	b_die("'$mandatory' missing fron config") unless defined($_CFG->{$mandatory});
    }
}

sub _execute_statement {
    my($self, $statement, $inst, $ignore_errors) = @_;
    my($cmd) = 'psql'
	. ' --pset pager'
	. ' --tuples-only'
	. ' --no-align'
	. ' --username ' . $inst->{username}
	. ' --no-password'
	. ' --dbname ' . $inst->{dbname}
	. ' --command "' . $statement . '"'
	. ' --host ' . $inst->{host}
	. ' --port ' . $inst->{port};
    $cmd .= ' 2>&1' if $ignore_errors;
    $ENV{PGPASSWORD} =  $inst->{password} if $inst->{password};
    my($res) = $self->piped_exec($cmd, undef, $ignore_errors);
    chomp($$res);
    return $$res;
}

sub _get_inst {
    my($self, $inst_name) = @_;
    my($defaults) = {
	host => 'localhost',
	port => 5432,
	dbname => 'postgres',
	username => 'postgres',
	password => 'postgres',     
	$_CFG->{pg_instances}->{_defaults} ? %{$_CFG->{pg_instances}->{_defaults}} : (),
    };
    return $defaults
	unless defined($inst_name);
    b_die('No such instance: ' . $inst_name)
	unless defined($_CFG->{pg_instances}->{$inst_name});
    return {
	%$defaults,
	%{$_CFG->{pg_instances}->{$inst_name}},
    };
}    

sub _get_primary_info {
    my($self, $inst) = @_;
    b_die($inst, ' does not have "archive mode" enabled')
	if _get_setting($self, 'archive_mode', $inst) ne 'on';
    my($timeout) = _get_setting($self, 'archive_timeout', $inst);
    b_die($inst, ' has "archive timeout" set to zero')
	if ($timeout == 0);
    my($archive_command) = _get_setting($self, 'archive_command', $inst);
    my($archive_dir) = $archive_command =~ /cp\s+%p\s+([^%]+)%f/;
    b_die($inst, ' has "archive command" set to "' . $archive_command
	. '", expected "cp %p /dir/%f"')
       unless ($archive_dir);
    my($data_dir) = _get_setting($self, 'data_directory', $inst);
    return ($archive_dir, $data_dir, $timeout);    
}    

sub _get_setting {
    my($self, $setting, $inst) = @_;
    return _execute_statement($self, "select setting from pg_settings where name='$setting'", $inst);
}


sub _println {
    print($_A->format_args(@_));
}


1;
