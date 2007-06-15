# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmUser;
use strict;
$Bivio::Biz::Model::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmUser::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmUser - interface to realm_user_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmUser;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmUser> is the create, read, update,
and delete interface to the C<realm_user_t> table.

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Die;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::RealmName;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> if not set.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} ||= Bivio::Type::DateTime->now;
    return $self->SUPER::create($values);
}

=for html <a name="execute_auth_user"></a>

=head2 static execute_auth_user(Bivio::Agent::Request req)

Loads this realm for this auth user.

=cut

sub execute_auth_user {
    my($proto, $req) = @_;
    my($user) = $req->get('auth_user') || Bivio::Die->die('no auth_user');
    $proto->new($req)->load({
        user_id => $user->get('realm_id'),
    });
    return;
}

=for html <a name="get_any_online_admin"></a>

=head2 get_any_online_admin() : Bivio::Biz::Model

Returns I<Model.RealmOwner> for any online Administrator for
I<Request.auth_realm>.  Dies if none (shouldn't be the case).

=cut

sub get_any_online_admin {
    my($self) = @_;
    $self->iterate_start('user_id', {});
    my($owner) = $self->new_other('RealmOwner');

    while ($self->iterate_next_and_load) {
        next unless $self->get('role')->is_admin;
        next if $owner->unauth_load_or_die({
            realm_id => $self->get('user_id'),
        })->is_offline_user;
        $self->iterate_end;
	return $owner;
    }
    $self->throw_die('DIE', {
	message => 'no admins found',
	entity => $self->get_request->unsafe_get('auth_realm'),
    });
    # DOES NOT RETURN
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_user_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            role => ['RealmRole.role', 'PRIMARY_KEY'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
#TODO: SECURITY: If user_id known, does that mean can get to all user's info?
	other => [
	    # User_1 is the realm, if the realm_type is a user.
	    [qw(realm_id Club.club_id User_1.user_id RealmOwner_1.realm_id)],
	    # User_2 is the the "realm_user"
	    [qw(user_id User_2.user_id RealmOwner_2.realm_id)],
	],
    };
}

=for html <a name="is_auth_user"></a>

=head2 is_auth_user() : boolean

=head2 static is_auth_user(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if the current row is the request's auth_user.

=cut

sub is_auth_user {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    my($auth_user) = $model->get_request->get('auth_user');
    return 0 unless $auth_user;
    return $model->get($model_prefix . 'user_id')
        eq $auth_user->get('realm_id') ? 1 : 0;
}

=for html <a name="is_sole_admin"></a>

=head2 is_sole_admin() : boolean

=head2 static is_sole_admin(Bivio::Biz::Model model, string model_prefix) : boolean

Returns true if this is the only online ADMINISTRATOR left in the realm.

=cut

sub is_sole_admin {
    my($proto, $model, $model_prefix) = shift->internal_get_target(@_);
    # Check to see if an admin at all.  This avoids a db query for most
    # realm users.
    return 0 unless $model->get($model_prefix . 'role')->is_admin;
#TODO: fix this code;  Should do_rows.  Indeed, should be RealmUserList.
    return Bivio::SQL::Connection->execute_one_row('
        SELECT count(*)
        FROM realm_owner_t, realm_user_t
        WHERE realm_user_t.realm_id = ?
        AND user_id != ?
        AND role IN ('
            . join(',', map($_->is_admin ? $_->as_sql_param : (),
                Bivio::Auth::Role->get_list)) . ")
        AND realm_user_t.user_id = realm_owner_t.realm_id
        AND realm_owner_t.name NOT LIKE '"
            . Bivio::Type::RealmName->OFFLINE_PREFIX . "\%'",
        [$model->get($model_prefix . 'realm_id',
            $model_prefix . 'user_id')])->[0] ? 0 : 1;
}

=for html <a name="update_role"></a>

=head2 update_role(self, Bivio::Auth::Role role) : self

Changes the role by deleting and recreating the RealmUser record.
Primary keys can't be update in bOP.

=cut

sub update_role {
    my($self, $role) = @_;
    return $self
        if $self->get('role') == $role;
    my($values) = $self->get_shallow_copy;
    $self->delete;
    return $self->create({
        %$values,
        role => $role,
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
