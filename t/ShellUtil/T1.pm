# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::ShellUtil::T1;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::IO::Log;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LOG) = 'ShellUtil/mylog.log';
Bivio::IO::Config->introduce_values({
    'Bivio::IO::Log' => {
	directory => Bivio::IO::File->pwd,
    },
    'Bivio::ShellUtil' => {
	map({(
	    $_ => {
    #TODO: due to a bug in introduce_values, all config must be set here
		daemon_log_file => $_LOG,
		daemon_max_children => 2,
		daemon_sleep_after_start => 1,
		daemon_sleep_after_reap => $_ eq 'rd1' ? 0 : 1,
		daemon_max_child_run_seconds => $_ eq 'rd3' ? 1 : 0,
		daemon_max_child_term_seconds => 0,
	    },
	)} qw(rd1 rd2 rd3)),
    },
});

sub USAGE {
    return '
Some usage string
';
}

sub echo {
    shift;
    return shift;
}

sub rd1 {
    my($self, $cfg_name) = @_;
    my($count) = 0;
    unlink(Bivio::IO::Log->file_name($_LOG));
    $cfg_name ||= 'rd1';
    $self->run_daemon(
	sub {
	    return
		if $count > 4;
	    return [
		[__PACKAGE__, 'rd1a', $count, $cfg_name],
		[__PACKAGE__, 'rd1a', $count, $cfg_name],
	    ]->[$count++ % 2];
	},
	$cfg_name,
    );
    return $self->read_log;
}

sub rd1a {
    my($self, $arg, $cfg_name) = @_;
    $self->initialize_ui;
    sleep($cfg_name eq 'rd3' ? 10 : 1);
    Bivio::IO::Alert->warn('myarg=', $arg);
    return;
}

sub read_log {
    my($self) = @_;
    return ${Bivio::IO::Log->read($_LOG)};
}

sub t1 {
    my($self) = @_;
    my($other) = $self->new_other(__PACKAGE__);
    $other->main('t1a');
    die('requests not the same')
	unless $other->get_request == $self->get_request;
    $other->get('t1a');
    return;
}

sub t1a {
    my($self) = @_;
    $self->put(t1a => 1);
    return;
}

1;
