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

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::MemberWithdrawalInfo::ISA = ('Bivio::Biz::ListModel');

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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	other => [
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
		name => 'withdrawal_realized_gain',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'show_realized_gain',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'pre_withdrawal_basis',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'adjusted_basis',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'basis_withdrawn',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'show_allocations',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

Populates the single row of data.

=cut

sub internal_load {
    my($self, @args) = @_;
    my($fields) = $self->{$_PACKAGE};

    # calling the superclass first puts this model on the request
    # and allows InstrumentTransferList to reference it during the
    # calculations
    $self->SUPER::internal_load(@args);
    my($req) = $self->get_request;
    my($properties) = $fields->{properties};

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
    $properties->{withdrawal_fee} = $math->neg(_get_transaction_amount($txn,
	    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FEE()));
    $properties->{withdrawal_amount} = $math->neg($entry->get('amount'));
    $properties->{cash_withdrawn} = $math->neg(_get_transaction_amount(
	    $txn, undef, Bivio::Type::EntryClass::CASH()));
    $properties->{withdrawal_adjustment} = $math->neg($math->round(
	    _get_transaction_amount($txn,
		    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_ADJUSTMENT()),
	    2));

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

    $properties->{withdrawal_realized_gain} = _add($properties, qw(
            member_tax_basis withdrawal_allocations cash_withdrawn
            member_instrument_cost_basis));
    $properties->{show_realized_gain} = 1;

    # partial withdrawals can't have a positive realized_gain
    if (($properties->{type} ==
	    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_PARTIAL_STOCK
	    || $properties->{type} ==
	    Bivio::Type::EntryType::MEMBER_WITHDRAWAL_PARTIAL_CASH)
	    && $math->compare($properties->{withdrawal_realized_gain}, 0)
	    <= 0) {
	$properties->{withdrawal_realized_gain} = 0;
	$properties->{show_realized_gain} = 0;
    }
    $properties->{withdrawal_value} = _add($properties, qw(
            cash_withdrawn instrument_fmv withdrawal_fee
            withdrawal_adjustment));
    $properties->{unit_value} = $math->div(
	    $properties->{withdrawal_value}, $properties->{units_withdrawn});

    $properties->{pre_withdrawal_basis} =
	    $math->neg($properties->{member_tax_basis});
    $properties->{adjusted_basis} = $math->neg(
	    $math->add($properties->{member_tax_basis},
		    $properties->{withdrawal_allocations}));
    $properties->{basis_withdrawn} = $math->add(
	    $properties->{cash_withdrawn},
	    $properties->{member_instrument_cost_basis});
    $properties->{withdrawal_allocations} = $math->neg(
	    $properties->{withdrawal_allocations});

    $properties->{show_allocations} = _get_show_allocations($req);
    return;
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Returns a single row with calculated values.

=cut

sub internal_load_rows {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {
	properties => {},
    };
    return [$fields->{properties}];
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

# _get_show_allocations(Bivio::Agent::Request req) : boolean
#
# Returns true if the current Bivio::Biz::Model::MemberAllocationList
# has data.
#
sub _get_show_allocations {
    my($req) = @_;
    my($list) = $req->get('Bivio::Biz::Model::MemberAllocationList');
    if ($list->get_result_set_size > 0) {
	$list->set_cursor_or_die(0);
	foreach my $tax (@{Bivio::Type::TaxCategory->get_club_tax_values}) {
	    my($name) = $tax->get_short_desc;
	    return 1 if $list->get($name) != 0;
	}
    }
    return 0;
}

# _get_transaction_amount(Bivio::Biz::Model::RealmTransaction txn, Bivio::Type::EntryType type, Bivio::Type::EntryClass class) : string
#
# Returns the entry amount for the specified transaction/type/class.
# Either type or class can be undef.
#
sub _get_transaction_amount {
    my($txn, $type, $class) = @_;
    my($entry) = Bivio::Biz::Model::Entry->new($txn->get_request);
    my($amount) = 0;
    if ($entry->unsafe_load(
	    realm_transaction_id => $txn->get('realm_transaction_id'),
	    defined($type)
		    ? (entry_type => $type)
		    : (class => $class))) {
	$amount = $entry->get('amount');
    }
    return $amount;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
