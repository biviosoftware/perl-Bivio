# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::PublicRealm;
use strict;
$Bivio::Biz::Action::PublicRealm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::PublicRealm::VERSION;

=head1 NAME

Bivio::Biz::Action::PublicRealm - sets realm_is_public attribute on the request

=head1 SYNOPSIS

    use Bivio::Biz::Action::PublicRealm;
    Bivio::Biz::Action::PublicRealm->execute($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::PublicRealm::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::PublicRealm> sets the C<realm_is_public> attribute
on the request.  This is used by lists, forms and UI modules to allow, but
restrict anonymous access.

=head1 REQUEST ATTRIBUTES

=over 4

=item user_can_modify_is_public : boolean

Set to true if user as "is_public" privs and the realm is public.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="ROLES"></a>

=head2 ROLES() : array_ref

Return list of roles which need to be managed for controlling public access

=cut

sub ROLES {
    return [
        Bivio::Auth::Role::ANONYMOUS(),
        Bivio::Auth::Role::USER(),
        Bivio::Auth::Role::WITHDRAWN(),
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Set C<realm_is_public> to I<true> if realm allows public access
to its club space.

Set C<is_realm_user> to I<true> is user is a member or guest.

=cut

sub execute {
    my($self, $req) = @_;
    $self->execute_simple($req);
    my($can_modify) = $req->get('realm_is_public')
#TODO: Need to work for all realms
	    && $req->get('auth_realm')->get('type')
		    == Bivio::Auth::RealmType::CLUB()
	    && $req->can_user_execute_task(
		    Bivio::Agent::TaskId::CLUB_ADMIN_PUBLIC())
		    ? 1 : 0;
    _trace('user_can_modify_is_public=', $can_modify) if $_TRACE;
    $req->put(user_can_modify_is_public => $can_modify);
    return 0;
}

=for html <a name="execute_simple"></a>

=head2 execute_simple(Bivio::Agent::Request req) : boolean

This version is used for lists which don't have forms, i.e. you
don't need to know about I<user_can_modify_is_public>.  This
was added to support L<Bivio::Biz::Util::File|Bivio::Biz::Util::File>.

=cut

sub execute_simple {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($user) = $req->get('auth_user');
    my($club_id) = $req->get('auth_id');
    my($role) = $req->get('auth_role');

    my($is_realm_user) = 0;
    # A user belongs to a realm if it plays a reasonable role in it
    if (defined($user) && !grep($role eq $_, @{ROLES()})) {
        $is_realm_user = 1;
    }
    # A realm is public if ANONYMOUS role has DOCUMENT_READ access
    my($rr) = Bivio::Biz::Model::RealmRole->new();
    my($realm_is_public) = 0;
    if ($rr->unauth_load(realm_id => $club_id,
            role => Bivio::Auth::Role::ANONYMOUS())) {
        my($ps) = $rr->get('permission_set');
        $realm_is_public = Bivio::Auth::PermissionSet->is_set(\$ps,
                Bivio::Auth::Permission::DOCUMENT_READ());
    }

    _trace('is_realm_user,realm_is_public=',
            $is_realm_user, ',', $realm_is_public) if $_TRACE;
    $req->put(
            is_realm_user => $is_realm_user,
            realm_is_public => $realm_is_public,
           );
    return 0;
}

#=PRIVATE METHODS


=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
