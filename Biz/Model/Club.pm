# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Club;
use strict;
$Bivio::Biz::Model::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Club::VERSION;

=head1 NAME

Bivio::Biz::Model::Club - interface to club_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::Club;
    Bivio::Biz::Model::Club->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Club::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Club> is the create, read, update,
and delete interface to the C<club_t> table.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Biz::ListModel;
use Bivio::Biz::Model::File;
use Bivio::Biz::Model::MemberTransactionList;
use Bivio::Biz::Model::RealmAdminList;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::RealmUserList;
use Bivio::Biz::Model::User;
use Bivio::IO::Trace;
use Bivio::Type::RealmName;


#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
#TODO: Need Location policy.  Probably need a field added to table.
#      which says where people want email sent from bivio.
my($_EMAIL_LIST) = Bivio::Biz::ListModel->new_anonymous({
    version => 1,
    other => [
	'Email.email',
	'RealmUser.role',
    ],
    auth_id => [qw(RealmUser.realm_id)],
    primary_key => [
	['RealmUser.user_id', 'Email.realm_id'],
    ],
});
my($_COUNT_ALL_WHERE_CLAUSE) =
        "name NOT LIKE '%"
	.Bivio::Type::RealmName::DEMO_CLUB()
	."'
        AND name NOT LIKE '%"
	.Bivio::Type::RealmName::TEST_SUFFIX()
	."'
        AND realm_type = "
        .Bivio::Auth::RealmType::CLUB()->as_sql_param;
my($_MEMBER_ROLES) = Bivio::Biz::Model::RealmUser::MEMBER_ROLES();
$_MEMBER_ROLES = Bivio::Auth::RoleSet->to_sql_list(\$_MEMBER_ROLES);

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes the club, and all of its related transactions, membership records,
and files. Also deletes any shadow members which are a member of the club.

=cut

sub cascade_delete {
    my($self) = @_;
    my($id) = $self->get('club_id');
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load_or_die(realm_id => $id);

    # delete tables which contain realm data, but not linked to
    # accounting transactions.
    _delete_all($id, qw(realm_invite_t tax_k1_t tax_1065_t mail_t));

    # delete files
    Bivio::Biz::Model::File->cascade_delete($realm);

    # Delete all accounting
    $self->delete_instruments_and_transactions;
    $self->delete_shadow_users;

    # Delete all from tables which are used by accounting and
    # aren't deleted by above.
    _delete_all($id, qw(realm_user_t realm_account_t expense_category_t));

    # Delete the club and then the realm
    $self->delete();
    $realm->cascade_delete;
    return;
}

=for html <a name="count_all"></a>

=head2 static count_all(Bivio::Agent::Request req) : int

Returns the total number of clubs.

=cut

sub count_all {
    my($proto, $req) = @_;
    return Bivio::SQL::Connection->execute_one_row(
	    "SELECT count(*)
            FROM realm_owner_t
            WHERE ".$_COUNT_ALL_WHERE_CLAUSE)->[0]
}

=for html <a name="count_all_members"></a>

=head2 static count_all_members(Bivio::Agent::Request req) : int

Returns the total number of members of L<count_all|"count_all"> clubs.

=cut

sub count_all_members {
    my($proto, $req) = @_;
    return Bivio::SQL::Connection->execute_one_row(
	    "SELECT count(DISTINCT user_id)
            FROM realm_user_t, realm_owner_t
            WHERE role IN $_MEMBER_ROLES
            AND realm_user_t.realm_id = realm_owner_t.realm_id
            AND $_COUNT_ALL_WHERE_CLAUSE")->[0];
}

=for html <a name="delete_instruments_and_transactions"></a>

=head2 delete_instruments_and_transactions()

Deletes all realm instruments and accounting transaction for the club.
Remove any shadow users which are currently club members.
This "cleans the slate" for the club books.

=cut

sub delete_instruments_and_transactions {
    my($self) = @_;
    my($id) = $self->get('club_id');
    my($req) = $self->get_request;

    # This makes sure you don't load another club and try to delete it
    # while operating in a different auth_realm.
    die("can't delete outside of auth_realm")
	    unless $id == $req->get('auth_id');

    foreach my $table (qw(
            realm_instrument_valuation_t
            member_entry_t
            realm_instrument_entry_t
            realm_account_entry_t
            expense_info_t
            entry_t
            account_sync_t
            realm_transaction_t
            realm_instrument_t
            member_allocation_t
            tax_1065_t)) {

	Bivio::SQL::Connection->execute('
                DELETE FROM '.$table.'
                WHERE realm_id=?',
		[$id]);
    }

    # need to reset any withdrawn members to member
    # otherwise they can't be deleted using the UI
    my($list) = Bivio::Biz::Model::RealmUserList->new($req);
    my($it) = $list->iterate_start({show_inactive => 1});
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    my($member) = Bivio::Type::Honorific::MEMBER();
    while ($list->iterate_next_and_load($it)) {
	next unless $list->get('RealmUser.role')
		== Bivio::Auth::Role::WITHDRAWN();
	$realm_user->load(user_id => $list->get('RealmUser.user_id'));
	$realm_user->update({
	    honorific=> $member,
	    role => $member->get_role,
	});
    }
    $list->iterate_end($it);

    return;
}

=for html <a name="delete_member_by_name"></a>

=head2 delete_member_by_name(string member) : boolean

Returns true if could delete.  Returns false if the member has
transactions associated, can't be .

=cut

sub delete_member_by_name {
    my($self, $member) = @_;
    my($id) = $self->get('club_id');
    my($req) = $self->get_request;

    # Find user
    my($user) = Bivio::Biz::Model::RealmOwner->new($req);
    $user->unauth_load_or_die(name => $member,
	   realm_type => Bivio::Auth::RealmType::USER());
    my($user_id) = $user->get('realm_id');

    # If has txns, can't delete.
    my($txn_list) = Bivio::Biz::Model::MemberTransactionList->new($req);
#TODO: This is broken unless $id is $auth_id.  Don't have (or want)
#      unauth_iterate_start.
    die('trying to delete outside auth_realm')
	    unless $id eq $req->get('auth_id');
    my($it) = $txn_list->iterate_start({parent_id => $user_id});
    my(%row);
    my($has_txn) = $txn_list->iterate_next($it, \%row);
    $txn_list->iterate_end($it);
    $user->throw_die('user has transactions') if $has_txn;

#TODO: Need to check for owner of Files and admin of Transactions

    # Delete RealmUser first to auth and lock record
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    $realm_user->load(
	    realm_id => $id, user_id => $user_id);
    $realm_user->delete();
    return;
}

=for html <a name="delete_shadow_users"></a>

=head2 delete_shadow_users()

Deletes the shadow users for this club.

=cut

sub delete_shadow_users {
    my($self) = @_;
    my($req) = $self->get_request;

    # This makes sure you don't load another club and try to delete it
    # while operating in a different auth_realm.
    die("can't delete outside of auth_realm")
	    unless $self->get('club_id') == $req->get('auth_id');

    # delete realm's existing shadow members
    my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
    my($user) = Bivio::Biz::Model::User->new($req);
    my($list) = Bivio::Biz::Model::RealmUserList->new($req);
    my($it) = $list->iterate_start({show_inactive => 1});
    while ($list->iterate_next_and_load($it)) {
	next unless $list->is_shadow_user;

	$realm_user->load(user_id => $list->get('RealmUser.user_id'));
	$realm_user->cascade_delete;
	$user->unauth_load(user_id => $list->get('RealmUser.user_id'));
	$user->cascade_delete;
    }
    $list->iterate_end($it);
    return;
}

=for html <a name="get_outgoing_emails"></a>

=head2 get_outgoing_emails() : array_ref

Returns an array of email addresses (string) for all members of the club
that have the MAIL_RECEIVE permission set for their role.

=cut

sub get_outgoing_emails {
    my($self) = @_;
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load_or_die(realm_id => $self->get('club_id'));
    # Get roles which are permitted to receive mail
    my($roles) = Bivio::Biz::Model::RealmRole->new($self->get_request)
            ->get_roles_for_permission($realm,
                    Bivio::Auth::Permission::MAIL_RECEIVE());
    $_EMAIL_LIST->unauth_load_all({auth_id => $self->get('club_id')});
    my($result) = [];
    while ($_EMAIL_LIST->next_row) {
        next unless Bivio::Auth::RoleSet->is_set(\$roles,
                $_EMAIL_LIST->get('RealmUser.role'));
	my($e) = $_EMAIL_LIST->get('Email.email');
	push(@$result, $e) if Bivio::Type::Email->is_valid($e);
    }
    return @$result ? $result : undef;
}

=for html <a name="has_transactions"></a>

=head2 has_transactions() : boolean

=head2 has_transactions(string start_date, string end_date) : boolean

Returns 1 if the club has any accounting transactions.

=cut

sub has_transactions {
    my($self, $start_date, $end_date) = @_;

    my($sql) = "
            SELECT COUNT(*)
            FROM realm_transaction_t
            WHERE realm_id=?";
    my($params) = [$self->get('club_id')];

    if (defined($start_date)) {
	$sql .= "
            AND realm_transaction_t.date_time
                BETWEEN $_SQL_DATE_VALUE AND $_SQL_DATE_VALUE";
	push(@$params, $start_date, $end_date);
    }

    my($sth) = Bivio::SQL::Connection->execute($sql, $params);
    my($count) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$count = $row->[0] || 0;
    }
    return $count ? 1 : 0;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'club_t',
	columns => {
            club_id => ['PrimaryId', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NONE'],
        },
	auth_id => 'club_id',
    };
}

=for html <a name="rename"></a>

=head2 rename(string new_name)

Renames the club to the new name.

=cut

sub rename {
    my($self, $new_name) = @_;

    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load(realm_id => $self->get('club_id'))
	    || die("couldn't load realm from club");

    # order is important here, because if the name is already taken
    # we will get a uniqeness constraint violation and a Form can
    # generate the proper error message.
    my($old_name) = $realm->get('name');
    $realm->update({name => $new_name});
    return;
}

#=PRIVATE METHODS

# _delete_all(string realm_id, string table, ...)
#
# Deletes all entries from tables.
#
sub _delete_all {
    my($realm_id, @tables) = @_;
    foreach my $t (@tables) {
	Bivio::SQL::Connection->execute("
                DELETE FROM $t
                WHERE realm_id=?",
		[$realm_id]);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
