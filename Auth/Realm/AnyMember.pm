# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::AnyMember;
use strict;
$Bivio::Auth::Realm::AnyMember::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::AnyMember - defines the realm which any user can access

=head1 SYNOPSIS

    use Bivio::Auth::Realm::AnyMember;
    Bivio::Auth::Realm::AnyMember->new();

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::AnyMember::ISA = ('Bivio::Auth::Realm');

=head1 DESCRIPTION

C<Bivio::Auth::Realm::AnyMember> defines the realm in which any registered
user who is also a club member can have access.
This realm may be cached statically as it doesn't have an owner.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::AnyMember

=cut

sub new {
    my($proto) = @_;
    return &Bivio::Auth::Realm::new($proto);
}

=head1 METHODS

=for html <a name="get_user_role"></a>

=head2 get_user_role(Bivio::Biz::PropertyModel::Club auth_user) : Bivio::Auth::Role

Returns the role the (to be) authenticated user plays in this realm.

=cut

sub get_user_role {
    my($self, $auth_user) = @_;
    return Bivio::Auth::Role::ANONYMOUS
	    unless $auth_user && (my($auth_id) = $auth_user->get('id'));
#TODO: Need a call get_clubs or something.
    die("not implemented");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
