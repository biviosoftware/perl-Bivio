# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmUser;
use strict;
$Bivio::Biz::Model::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmUser - interface to realm_user_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmUser;
    Bivio::Biz::Model::RealmUser->new($req);

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
use Bivio::Auth::RoleSet;
use Bivio::IO::Alert;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;

#=VARIABLES
my($_ACTIVE_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_ACTIVE_ROLES,
	Bivio::Auth::Role::GUEST(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
	);
my($_MEMBER_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_MEMBER_ROLES,
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
       );

my($_MEMBER_OR_WITHDRAWN_ROLES) = '';
Bivio::Auth::RoleSet->set(\$_MEMBER_OR_WITHDRAWN_ROLES,
	Bivio::Auth::Role::WITHDRAWN(),
	Bivio::Auth::Role::MEMBER(),
	Bivio::Auth::Role::ACCOUNTANT(),
	Bivio::Auth::Role::ADMINISTRATOR(),
       );

=head1 CONSTANTS

=cut

=for html <a name="VALID_ACTIVE_ROLES"></a>

=head2 VALID_ACTIVE_ROLES : string

Value is a L<Bivio::Auth::RoleSet|Bivio::Auth::RoleSet>
includes Guest, Member, Accountant, and Administrator.

=cut

sub VALID_ACTIVE_ROLES {
    return $_ACTIVE_ROLES;
}

=for html <a name="MEMBER_ROLES"></a>

=head2 MEMBER_ROLES : string

Value is a L<Bivio::Auth::RoleSet|Bivio::Auth::RoleSet>.

=cut

sub MEMBER_ROLES {
    return $_MEMBER_ROLES;
}

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes the user from the realm including any invites.
Does not delete transactions or tax tables in the realm.

=cut

sub cascade_delete {
    my($self) = @_;
    my($realm_id, $user_id) = $self->get('realm_id', 'user_id');

    # need a group delete
    # could have > 1 invite in the same realm
    Bivio::SQL::Connection->execute('
            DELETE FROM realm_invite_t
            WHERE realm_user_id=?
            AND realm_id=?',
	    [$user_id, $realm_id]);
    return $self->delete();
}

=for html <a name="change_ownership"></a>

=head2 change_ownership(string user_id, boolean include_k1)

Changes all tables owned in the current realm by this user to the specified
user id.

If 'include_k1' is true, then the member's TaxK1 record will be moved.

=cut

sub change_ownership {
    my($self, $user_id, $include_k1) = @_;
    my($req) = $self->get_request;

    my(@tables) = qw(member_entry_t realm_transaction_t file_t realm_invite_t
            member_allocation_t);
    push(@tables, 'tax_k1_t') if $include_k1;

    # change all references to the user
    foreach my $table (@tables) {
	Bivio::SQL::Connection->execute("
                UPDATE $table
                SET user_id=?
                WHERE user_id=?
                AND realm_id=?",
		[$user_id, $self->get('user_id'), $req->get('auth_id')]);
    }
    return;
}

#TODO: Add code to make sure don't delete last admin.
#      See ClubUserForm.  Throw type error on field and wille
#      be picked up by form.

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} ||= Bivio::Type::DateTime->now();
    return $self->SUPER::create($values);
}

=for html <a name="get_first_payment_date"></a>

=head2 get_first_payment_date() : string

Returns the first payment/opening balance date for the user in the current
realm's accounts.

Returns undef if no value exists. (User has never paid into realm)

=cut

sub get_first_payment_date {
    my($self) = @_;

    my($date_param) = Bivio::Type::DateTime->from_sql_value('MIN(date_time)');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT $date_param
            FROM realm_transaction_t, entry_t, member_entry_t
            WHERE realm_transaction_t.realm_transaction_id
                = entry_t.realm_transaction_id
            AND entry_t.entry_id=member_entry_t.entry_id
            AND realm_transaction_t.realm_id=?
            AND member_entry_t.user_id=?
            AND member_entry_t.units != 0",
	    [$self->get('realm_id', 'user_id')]);
    my($date) = undef;
    my($row);
    if ($row = $sth->fetchrow_arrayref) {
	$date = $row->[0];
    }
    return $date;
}

=for html <a name="execute_auth_user"></a>

=head2 static execute_auth_user(Bivio::Agent::Request req)

Loads this realm for this auth user.

=cut

sub execute_auth_user {
    my($proto, $req) = @_;
    my($user) = $req->get('auth_user');
    Bivio::IO::Alert->die('no auth_user') unless $user;
    my($self) = $proto->new($req);
    $self->load(user_id => $user->get('realm_id'));
    return;
}

=for html <a name="has_transactions"></a>

=head2 has_transactions() : boolean

Returns 1 if the user has accounting transactions within the realm.

=cut

sub has_transactions {
    my($self) = @_;

    my($sth) = Bivio::SQL::Connection->execute('
            SELECT COUNT(*)
            FROM member_entry_t
            WHERE realm_id=?
            AND user_id=?',
	    [$self->get('realm_id', 'user_id')]);
    my($found_transactions) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$found_transactions = $row->[0];
    }
    return $found_transactions > 0;
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
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            user_id => ['PrimaryId', 'PRIMARY_KEY'],
            role => ['Bivio::Auth::Role', 'NOT_NULL'],
	    honorific => ['Honorific', 'NOT_ZERO_ENUM'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
#TODO: SECURITY: If user_id known, does that mean can get to all user's info?
	other => [
	    # User_1 is the realm, if the realm_type is a user.
	    [qw(realm_id Club.club_id User_1.user_id RealmOwner_1.realm_id)],
	    # User_2 is the the "realm_user"
	    [qw(user_id User_2.user_id  RealmOwner_2.realm_id)],
	],
    };
}

=for html <a name="is_guest"></a>

=head2 is_guest() : boolean

=head2 static is_guest(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns true if the user is a GUEST.

In the second form, I<list_model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub is_guest {
	my($self) = shift;
	Bivio::Biz::Model::RealmUser->format($self, 'RealmUser.', @_);
    }

=cut

sub is_guest {
    my($self, $list_model, $model_prefix) = @_;
    $model_prefix ||= '';
    $list_model ||= $self;
    return $list_model->get($model_prefix.'role') ==
	    Bivio::Auth::Role::GUEST() ? 1 : 0;
}

=for html <a name="is_member"></a>

=head2 is_member() : boolean

=head2 static is_member(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns true if the user is a member or above, i.e. I<role> must
be MEMBER, ACCOUNT, or ADMINISTRATOR.

In the second form, I<list_model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub is_member {
	my($self) = shift;
	Bivio::Biz::Model::RealmUser->format($self, 'RealmUser.', @_);
    }

=cut

sub is_member {
    my($self, $list_model, $model_prefix) = @_;
    $model_prefix ||= '';
    $list_model ||= $self;
    return Bivio::Auth::RoleSet->is_set(\$_MEMBER_ROLES,
	    $list_model->get($model_prefix.'role'));
}

=for html <a name="is_member_or_guest"></a>

=head2 is_member_or_guest() : boolean

=head2 static is_member_or_guest(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Is this a member, accountant, admin, or a guest?

=cut

sub is_member_or_guest {
    my($self, $list_model, $model_prefix) = @_;
    $model_prefix ||= '';
    $list_model ||= $self;
    return unless Bivio::Auth::RoleSet->is_set(\$_ACTIVE_ROLES,
	    $list_model->get($model_prefix.'role'));
}

=for html <a name="is_member_or_withdrawn"></a>

=head2 is_member_or_withdrawn() : boolean

=head2 static is_member_or_withdrawn(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns true if the user is a member or above, i.e. I<role> must
be WITHDRAWN, MEMBER, ACCOUNT, or ADMINISTRATOR.

=cut

sub is_member_or_withdrawn {
    my($self, $list_model, $model_prefix) = @_;
    $model_prefix ||= '';
    $list_model ||= $self;
    return Bivio::Auth::RoleSet->is_set(\$_MEMBER_OR_WITHDRAWN_ROLES,
	    $list_model->get($model_prefix.'role'));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
