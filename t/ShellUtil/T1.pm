# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::ShellUtil::T1;
use strict;
$Bivio::t::ShellUtil::T1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::t::ShellUtil::T1::VERSION;

=head1 NAME

Bivio::t::ShellUtil::T1 - test shell util

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::t::ShellUtil::T1;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::t::ShellUtil::T1::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::t::ShellUtil::T1>

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string



=cut

sub USAGE {
    return '
Some usage string
';
}

#=IMPORTS
use Bivio::IO::Log;
use Bivio::IO::File;

#=VARIABLES
my($_LOG) = 'ShellUtil/mylog.log';
use Bivio::IO::Config;
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

=head1 METHODS

=cut

=for html <a name="rd1"></a>

=head2 rd1(string cfg_name)

Writes a message to a log file.

=cut

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

=for html <a name="rd1a"></a>

=head2 rd1a(int arg, string cfg_name)

Write a message to the log and sleep.

=cut

sub rd1a {
    my($self, $arg, $cfg_name) = @_;
    $self->initialize_ui;
    sleep($cfg_name eq 'rd3' ? 10 : 1);
    Bivio::IO::Alert->warn('myarg=', $arg);
    return;
}

=for html <a name="read_log"></a>

=head2 read_log() : string

Returns the log

=cut

sub read_log {
    my($self) = @_;
    return ${Bivio::IO::Log->read($_LOG)};
}

=for html <a name="t1"></a>

=head2 t1(string arg1) : string

Called with argument

=cut

sub t1 {
    my($self) = @_;
    my($other) = $self->new_other(__PACKAGE__);
    $other->main('t1a');
    die('requests not the same')
	unless $other->get_request == $self->get_request;
    $other->get('t1a');
    return;
}

=for html <a name="t1a"></a>

=head2 t1a()

Indicates was called.

=cut

sub t1a {
    my($self) = @_;
    $self->put(t1a => 1);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
