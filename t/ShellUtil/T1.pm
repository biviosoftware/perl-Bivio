# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
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
	rd1 => {
#TODO: due to a bug in introduce_values, all config must be set here
	    daemon_log_file => $_LOG,
	    daemon_max_children => 2,
	    daemon_sleep_after_start => 1,
	},
    },
});

=head1 METHODS

=cut

=for html <a name="rd1"></a>

=head2 rd1(string arg)

Writes a message to a log file.

=cut

sub rd1 {
    my($self, $arg) = @_;
    my($count) = 0;
    unlink(Bivio::IO::Log->file_name($_LOG));
    $self->run_daemon(
	sub {
	    return
		if $count > 4;
	    return [
		[__PACKAGE__, 'rd1a', $count],
		[__PACKAGE__, 'rd1a', $count],
	    ]->[$count++ % 2];
	},
	'rd1',
    );
    return;
}

=for html <a name="rd1a"></a>

=head2 rd1a(int arg)

Write a message to the log and sleep.

=cut

sub rd1a {
    my($self, $arg) = @_;
    $self->initialize_ui;
    Bivio::IO::Alert->warn('myarg=', $arg);
    sleep(1);
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

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
