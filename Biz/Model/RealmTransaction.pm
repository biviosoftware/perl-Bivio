# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmTransaction;
use strict;
$Bivio::Biz::Model::RealmTransaction::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmTransaction::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmTransaction - interface to realm_transaction_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmTransaction;
    Bivio::Biz::Model::RealmTransaction->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmTransaction::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmTransaction> is the create, read, update,
and delete interface to the C<realm_transaction_t> table.

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::SQL::Connection;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::Honorific;
use Bivio::Type::Integer;
use Bivio::Biz::Model::MemberEntry;
use Bivio::Biz::Model::RealmUser;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this transaction, and all its entires, member entries,
instrument entries, and account entries.

Note: this method doesn't audit the books after the date. The caller
is responsible for ensuring the books are audited after this operation.

=cut

sub cascade_delete {
    my($self) = @_;
    my($id) = $self->get('realm_transaction_id');

    _pre_delete($self);

    # delete member, instrument, and account entries
    # and cash expenses
    foreach my $table (qw(member_entry_t realm_instrument_entry_t
	    realm_account_entry_t expense_info_t)) {
	Bivio::SQL::Connection->execute('
                DELETE FROM '.$table.'
                WHERE entry_id IN (
                SELECT entry_id FROM entry_t
                WHERE realm_transaction_id=?)',
		[$id]);
    }

    # delete entries
    foreach my $table (qw)entry_t account_sync_t)) {
	Bivio::SQL::Connection->execute('
                DELETE FROM '.$table.'
                WHERE realm_transaction_id=?',
		[$id]);
    }

    # delete the transaction
    $self->delete();
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : Bivio::Biz::Model::RealmTransaction

Overrides PropertyModel::create() to default realm_id to the current realm.
Defaults the user_id to the current auth_user.

=cut

sub create {
    my($self, $new_values) = @_;
    my($req) = $self->get_request;
    $new_values->{realm_id} = $req->get('auth_realm')->get('owner')->get(
	    'realm_id') unless exists($new_values->{realm_id});
    $new_values->{user_id} = $req->get('auth_user')->get('realm_id')
	    unless exists($new_values->{user_id});
    $new_values->{modified_date_time} = Bivio::Type::DateTime->now
	    unless exists($new_values->{modified_date_time});
    return $self->SUPER::create($new_values);
}

=for html <a name="generate_entry_remark"></a>

=head2 generate_entry_remark() : string

=head2 generate_entry_remark(string class, string entry_id) : string

Return an appropriate remark for the entry.
By default, the source_class of the transaction is used to generate the
remark.

=cut

sub generate_entry_remark {
    my($self, $class, $entry_id) = @_;

    my($remark);
    $class ||= $self->get('source_class');

    if ($class eq Bivio::Type::EntryClass::INSTRUMENT()) {
	$remark = _generate_instrument_remark($self, $entry_id);
    }
    elsif ($class eq Bivio::Type::EntryClass::MEMBER()) {
	$remark = _generate_member_remark($self, $entry_id);
    }
    elsif ($class eq Bivio::Type::EntryClass::CASH()) {
	$remark = _generate_account_remark($self, $entry_id);
    }
    else {
	die("invalid entry class $class");
    }
    return $remark;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_transaction_t',
	columns => {
            realm_transaction_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            source_class => ['EntryClass', 'NOT_NULL'],
#TODO: Change field name. This was originally a date_time, but really,
#      it can't be a date_time, because we don't allow users to enter
#      it as a date_time.
            date_time => ['Date', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            remark => ['Text', 'NONE'],
            broker_code => ['Name', 'NONE'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(user_id User.user_id)],
	],
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Automatically sets modified_date_time.

=cut

sub update {
    my($self, $new_values) = (shift, shift);
    $new_values->{modified_date_time} = Bivio::Type::DateTime->now
	    unless exists($new_values->{modified_date_time});
    return $self->SUPER::update($new_values, @_);
}

#=PRIVATE METHODS

# _generate_account_remark() : string
#
# _generate_account_remark(string entry_id) : string
#
# Returns the account name.
#
sub _generate_account_remark {
    my($self, $entry_id) = @_;

    my($sth);
    if (defined($entry_id)) {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_account_t.name
            FROM entry_t, realm_account_entry_t, realm_account_t
            WHERE entry_t.entry_id=?
            AND entry_t.entry_id = realm_account_entry_t.entry_id
            AND realm_account_entry_t.realm_account_id
                = realm_account_t.realm_account_id
            AND realm_account_t.realm_id=?',
	    [$entry_id, $self->get('realm_id')]);
    }
    else {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_account_t.name
            FROM entry_t, realm_account_entry_t, realm_account_t
            WHERE entry_t.realm_transaction_id=?
            AND entry_t.entry_id = realm_account_entry_t.entry_id
            AND realm_account_entry_t.realm_account_id
                = realm_account_t.realm_account_id
            AND realm_account_t.realm_id=?',
	    [$self->get('realm_transaction_id', 'realm_id')]);
    }
    my($result);
    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	$result ||= $row->[0].' Account';
	# iterate the whole result set so the cursor closes
	# there is only one row anyway
    }
    # guaranteed result if class is cash
    return $result;
}

# _generate_instrument_remark() : string
#
# _generate_instrument_remark(string entry_id) : string
#
# [<count> Shares ] <name>
#
sub _generate_instrument_remark {
    my($self, $entry_id) = @_;

    my($sth);
    if (defined($entry_id)) {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_instrument_t.name || instrument_t.name,
                realm_instrument_entry_t.count,
                entry_t.entry_type
            FROM entry_t, realm_instrument_entry_t, realm_instrument_t,
                instrument_t
            WHERE entry_t.entry_id=?
            AND entry_t.entry_id = realm_instrument_entry_t.entry_id
            AND realm_instrument_entry_t.realm_instrument_id
                = realm_instrument_t.realm_instrument_id
            AND realm_instrument_t.instrument_id
                = instrument_t.instrument_id (+)
            AND realm_instrument_t.realm_id=?',
	    [$entry_id, $self->get('realm_id')]);
    }
    else {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_instrument_t.name || instrument_t.name,
                realm_instrument_entry_t.count,
                entry_t.entry_type
            FROM entry_t, realm_instrument_entry_t, realm_instrument_t,
                instrument_t
            WHERE entry_t.realm_transaction_id=?
            AND entry_t.entry_id = realm_instrument_entry_t.entry_id
            AND realm_instrument_entry_t.realm_instrument_id
                = realm_instrument_t.realm_instrument_id
            AND realm_instrument_t.instrument_id
                = instrument_t.instrument_id (+)
            AND realm_instrument_t.realm_id=?',
	    [$self->get('realm_transaction_id', 'realm_id')]);
    }

    my($result) = '';
    my($total) = 0;
    my($name) = '';
    while (my $row = $sth->fetchrow_arrayref) {
	my($count, $type);
	($name, $count, $type) = @$row;

	if (defined($entry_id)) {
	    $total += abs($count);
	}
	elsif ($type == Bivio::Type::EntryType::INSTRUMENT_SPLIT()->as_int
		|| $type == Bivio::Type::EntryType::INSTRUMENT_SPINOFF()
		->as_int
		|| $type == Bivio::Type::EntryType::INSTRUMENT_MERGER()
		->as_int) {
	    # skipping
	}
	else {
	    $total += abs($count);
	}
    }

    # get the grammar right
    if ($total == 1) {
	$result = '1 Share ';
    }
    elsif ($total != 0) {
	$result = $total.' Shares ';
    }

    # guaranteed result if class is instrument
    return $result.$name;
}

# _generate_member_remark() : string
#
# _generate_member_remark(string entry_id) : string
#
# If the number of member entries is > 1 then
# 'Deposits for '.<number>.' members' is returned for payment and fees.
# Otherwise the member display_name.
#
sub _generate_member_remark {
    my($self, $entry_id) = @_;

    my($sth);
    if (defined($entry_id)) {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_owner_t.display_name, entry_t.entry_type
            FROM entry_t, member_entry_t, realm_owner_t
            WHERE entry_t.entry_id=?
            AND entry_t.entry_id = member_entry_t.entry_id
            AND member_entry_t.user_id = realm_owner_t.realm_id
            AND member_entry_t.realm_id=?',
	    [$entry_id, $self->get('realm_id')]);
    }
    else {
	$sth = Bivio::SQL::Connection->execute('
            SELECT realm_owner_t.display_name, entry_t.entry_type
            FROM entry_t, member_entry_t, realm_owner_t
            WHERE entry_t.realm_transaction_id=?
            AND entry_t.entry_id = member_entry_t.entry_id
            AND member_entry_t.user_id = realm_owner_t.realm_id
            AND member_entry_t.realm_id=?',
	    [$self->get('realm_transaction_id', 'realm_id')]);
    }

    my($result);
    my($first_type);
    my($count) = 0;
    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	$result ||= $row->[0];
	$first_type ||= Bivio::Type::EntryType->from_int($row->[1]);
	$count++;
    }
    # change remark for group entries
    if ($count > 1 && ($first_type eq Bivio::Type::EntryType::MEMBER_PAYMENT()
	   || $first_type eq Bivio::Type::EntryType::MEMBER_PAYMENT_FEE())) {
	$result = 'Deposits for '.$count.' members';
    }
    # guaranteed result if class is member
    return $result;
}

# _pre_delete()
#
# Performs any pre-delete processing. For now this means resetting a
# member's state after a full withdrawal is deleted.
#
sub _pre_delete {
    my($self) = @_;
    my($req) = $self->get_request;

#TODO: this isn't modular, need a better approach for post delete processing

    # if this is a full withdrawal, then reset the member's status to member
    my($sth) = Bivio::SQL::Connection->execute('
            SELECT entry_id
            FROM entry_t
            WHERE realm_transaction_id=?
            AND class=?
            AND entry_type in (?,?)',
	    [$self->get('realm_transaction_id'),
		    Bivio::Type::EntryClass::MEMBER->as_sql_param,
		    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FULL_CASH
		    ->as_sql_param,
		    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FULL_STOCK
		    ->as_sql_param]);

    while (my $row = $sth->fetchrow_arrayref) {
	my($entry_id) = $row->[0];

	# set the target status to MEMBER if it is WITHDRAWN
	my($member_entry) = Bivio::Biz::Model::MemberEntry->new($req);
	$member_entry->load(entry_id => $entry_id);
	my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
	$realm_user->load(user_id => $member_entry->get('user_id'));

	if ($realm_user->get('role') == Bivio::Auth::Role::WITHDRAWN()) {
	    my($honorific) = Bivio::Type::Honorific::MEMBER();
	    $realm_user->update({
		role => $honorific->get_role,
		honorific => $honorific,
	    });
	}
	last;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
