# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Support;
use strict;
$Bivio::Auth::Support::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Support::VERSION;

=head1 NAME

Bivio::Auth::Support - miscellaneous site specific auth functions

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Support;

=cut

=head1 EXTENDS

L<Bivio::Delegator>

=cut

use Bivio::Delegator;
@Bivio::Auth::Support::ISA = ('Bivio::Delegator');

=head1 DESCRIPTION

C<Bivio::Auth::Support> implements miscellaneous site specific support
functions.  The methods must be implemented by the delegates.
See L<Bivio::Delegate::SimpleAuthSupport|Bivio::Delegate::SimpleAuthSupport>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_auth_user"></a>

=head2 abstract static get_auth_user(Bivio::Agent::Request req) : Bivio::Biz::Model

Returns a Model.RealmOwner for this request which is used to set
the auth_user.

=cut

$_ = <<'}'; # emacs
sub get_auth_user {
}

=for html <a name="load_permissions"></a>

=head2 abstract static load_permissions(Bivio::Auth::Realm realm, Bivio::Auth::Role role, Bivio::Agent::Request req) : Bivio::Auth::PermissionSet

Returns the permission set for this I<realm>, I<role>, and I<req>.

=cut

$_ = <<'}'; # emacs
sub load_permissions {
}

=for html <a name="task_permission_ok"></a>

=head2 abstract static task_permission_ok(Bivio::Auth::PermissionSet user, Bivio::Auth::PermissionSet task, Bivio::Agent::Request req) : boolean

Evaluates I<user> permissions satisfy I<task> required permissions.  The
basic formula is something like:

    return ($privileges & $required) eq $required ? 1 : 0;

=cut

$_ = <<'}'; # emacs
sub task_permission_ok {
}

=for html <a name="unsafe_get_user_pref"></a>

=head2 abstract static unsafe_get_user_pref(Bivio::Agent::Request req, string preference, ref value) : boolean

Sets I<value> only if preferences can be loaded for this user.
Returns true if preference could be loaded.

#TODO: This probably belongs somewhere else.

=cut

$_ = <<'}'; # emacs
sub unsafe_get_user_pref {
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
