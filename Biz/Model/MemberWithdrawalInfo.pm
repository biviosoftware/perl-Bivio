# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MemberWithdrawalInfo;
use strict;
$Bivio::Biz::Model::MemberWithdrawalInfo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MemberWithdrawalInfo - member withdrawal information

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberWithdrawalInfo;
    Bivio::Biz::Model::MemberWithdrawalInfo->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MemberWithdrawalInfo::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberWithdrawalInfo> member withdrawal information

=cut

#=IMPORTS
use Bivio::Biz::Model::InstrumentTransferList;
use Bivio::Type::Amount;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($math) = 'Bivio::Type::Amount';

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads all values.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    # get the withdrawal entry info
    my($entry) = $req->get('Bivio::Biz::Model::Entry');
    my($txn) = Bivio::Biz::Model::RealmTransaction->new($req);
    $txn->load(realm_transaction_id => $entry->get('realm_transaction_id'));
    $req->put(report_date => $txn->get('date_time'));

    my($member_entry) = $req->get('Bivio::Biz::Model::MemberEntry');
    my($user_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $user_realm->unauth_load_or_die(realm_id => $member_entry->get('user_id'));

    $properties->{realm_id} = $req->get('auth_id');
    $properties->{user_id} = $member_entry->get('user_id');
    $properties->{name} = $user_realm->get('display_name');
    $properties->{type} = $entry->get('entry_type');
    $properties->{transaction_date} = $txn->get('date_time'),
    $properties->{member_valuation_date} =
	    $member_entry->get('valuation_date');

    $properties->{units_withdrawn} = $math->neg($member_entry->get('units'));
    $properties->{withdrawal_fee} = $math->neg(_get_fee($txn));
    $properties->{withdrawal_amount} = $math->neg($entry->get('amount'));
    $properties->{cash_withdrawn} = $math->neg(_get_cash_withdrawn($txn));
    $properties->{withdrawal_adjustment} = $math->neg($math->round(
	    _get_adjustment($txn), 2));

    my($transfer_list) = Bivio::Biz::Model::InstrumentTransferList->new($req);
    $transfer_list->load_all;

    $properties->{transfer_valuation_date} =
	    $transfer_list->get_transfer_valuation_date;
    $properties->{instrument_fmv} = $math->round(
	    $transfer_list->get_summary->get('market_value'), 2);
    $properties->{member_tax_basis} = $math->round($math->neg(
	    $transfer_list->get_member_tax_basis), 2);
    $properties->{member_instrument_cost_basis} = $math->round(
	    $transfer_list->get_summary->get('member_cost_basis'), 2);

    $properties->{withdrawal_allocations} = $math->round($math->neg(
	    $transfer_list->get_allocations), 2);

    $properties->{realized_gain} = _add($properties, qw(
            member_tax_basis withdrawal_allocations cash_withdrawn
            member_instrument_cost_basis));

    # partial withdrawals can't have a positive realized_gain
    if ($properties->{type} ==
	    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_PARTIAL_STOCK
	    && $math->compare($properties->{realized_gain}, 0) < 0) {
	$properties->{realized_gain} = 0;
    }
    $properties->{withdrawal_value} = _add($properties, qw(
            cash_withdrawn instrument_fmv withdrawal_fee
            withdrawal_adjustment));
    $properties->{unit_value} = $math->div(
	    $properties->{withdrawal_value}, $properties->{units_withdrawn});

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	hidden => [
	    {
		name => 'user_id',
		type => 'PrimaryId',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'type',
		type => 'Bivio::Type::EntryType',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'transaction_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'member_valuation_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'transfer_valuation_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'unit_value',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'units_withdrawn',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'withdrawal_value',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'withdrawal_fee',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'withdrawal_amount',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'cash_withdrawn',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'instrument_fmv',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'withdrawal_adjustment',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'member_tax_basis',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'withdrawal_allocations',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'member_instrument_cost_basis',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'realized_gain',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

#=PRIVATE METHODS

# _add($properties, string field, ...) : string
#
# Returns the sum of the specified property fields.
#
sub _add {
    my($properties, @fields) = @_;
    my($sum) = 0;
    foreach my $field (@fields) {
	$sum = $math->add($sum, $properties->{$field});
    }
    return $sum;
}

# _get_adjustment(Bivio::Biz::Model::RealmTransaction txn) : string
#
# Returns any adjustment associated with the specified withdrawal
# transaction.
#
sub _get_adjustment {
    my($txn) = @_;
    my($entry) = Bivio::Biz::Model::Entry->new($txn->get_request);
    my($adjustment) = 0;
    if ($entry->unsafe_load(
	    realm_transaction_id => $txn->get('realm_transaction_id'),
	    entry_type =>
	    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_ADJUSTMENT())) {
	$adjustment = $entry->get('amount');
    }
    return $adjustment;
}

# _get_cash_withdrawn(Bivio::Biz::Model::RealmTransaction txn) : string
#
# Returns the cash amount for the specified withdrawal transaction.
#
sub _get_cash_withdrawn {
    my($txn) = @_;
    my($entry) = Bivio::Biz::Model::Entry->new($txn->get_request);
    my($cash) = 0;
    if ($entry->unsafe_load(
	    realm_transaction_id => $txn->get('realm_transaction_id'),
	    class => Bivio::Type::EntryClass::CASH())) {
	$cash = $entry->get('amount');
    }
    return $cash;
}

# _get_fee(Bivio::Biz::Model::RealmTransactions txn) : string
#
# Returns any fee associated with the specified withdrawal transaction.
#
sub _get_fee {
    my($txn) = @_;
    my($entry) = Bivio::Biz::Model::Entry->new($txn->get_request);
    my($fee) = 0;
    if ($entry->unsafe_load(
	    realm_transaction_id => $txn->get('realm_transaction_id'),
	    entry_type => Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FEE())) {
	$fee = $entry->get('amount');
    }
    return $fee;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
