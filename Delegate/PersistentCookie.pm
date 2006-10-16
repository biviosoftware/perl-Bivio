# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::PersistentCookie;
use strict;
$Bivio::Delegate::PersistentCookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::PersistentCookie::VERSION;

=head1 NAME

Bivio::Delegate::PersistentCookie - persistent HTTP cookie management

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::PersistentCookie;

=cut

=head1 EXTENDS

L<Bivio::Delegate::Cookie>

=cut

use Bivio::Delegate::Cookie;
@Bivio::Delegate::PersistentCookie::ISA = ('Bivio::Delegate::Cookie');

=head1 DESCRIPTION

C<Bivio::Delegate::PersistentCookie>

B<DEPRECATED>. Use L<Bivio::Delegate::Cookie|"Bivio::Delegate::Cookie">.

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, Apache::Request r) : Bivio::Delegate::PersistentCookie

Creates a new PersistentCookie.

=cut

sub new {
    my($proto) = shift;
    return $proto->SUPER::new(@_);
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
