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

#=VARIABLES

=head1 METHODS

=cut

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
