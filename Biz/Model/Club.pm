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
use Bivio::Auth::RoleSet;
use Bivio::Biz::Accounting::Ratio;
use Bivio::Biz::Model::RealmUser;
use Bivio::Type::DateTime;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
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
my($_COUNT_ALL_MEMBERS_RATIO);
_compute_count_all_members_ratio();

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this club and all its related realm information. Also deletes
any offline members which are a member of the club.

=cut

sub cascade_delete {
    my($self) = @_;
    my($realm) = Bivio::Biz::Model->new($self->get_request, 'RealmOwner')
	    ->unauth_load_or_die(realm_id => $self->get('club_id'));

    # need to load the user list first, delete offline members last
    my($user_list) = Bivio::Biz::Model->new($self->get_request,
	    'RealmUserList')->load_all_with_inactive;
    $self->SUPER::cascade_delete;
    $realm->cascade_delete;
    $user_list->delete_offline_users;
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

=head2 static count_all_members(Bivio::Agent::Request req) : Bivio::Type::Amount

Returns the total number of members of L<count_all|"count_all"> clubs.

=cut

sub count_all_members {
    my($proto, $req) = @_;
    return Bivio::Type::Amount->round(
	    $_COUNT_ALL_MEMBERS_RATIO->multiply(
		    Bivio::SQL::Connection->execute_one_row(
			    "SELECT count(user_id)
                            FROM realm_user_t")->[0]),
	    0);
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

=for html <a name="has_transactions"></a>

=head2 has_transactions() : boolean

=head2 has_transactions(string start_date, string end_date) : boolean

Returns 1 if the club has any accounting transactions.

#TODO: move somewhere else, Accounting::Util?

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
            club_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    start_date => ['Date', 'NONE'],
        },
	auth_id => 'club_id',
    };
}

#=PRIVATE METHODS

# _compute_count_all_members_ratio()
#
# This value is computed once at server startup.
#
sub _compute_count_all_members_ratio {
    $_COUNT_ALL_MEMBERS_RATIO = Bivio::Biz::Accounting::Ratio->new(
	    Bivio::SQL::Connection->execute_one_row(
		"SELECT count(DISTINCT user_id)
                FROM realm_user_t, realm_owner_t
                WHERE role IN $_MEMBER_ROLES
                AND realm_user_t.realm_id = realm_owner_t.realm_id
                AND $_COUNT_ALL_WHERE_CLAUSE")->[0],
	    Bivio::SQL::Connection->execute_one_row(
	        "SELECT count(user_id)
                FROM realm_user_t")->[0]);
    _trace($_COUNT_ALL_MEMBERS_RATIO) if $_TRACE;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
