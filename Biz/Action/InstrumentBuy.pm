# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::InstrumentBuy;
use strict;
$Bivio::Biz::Action::InstrumentBuy::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::InstrumentBuy - instrument purchase transaction

=head1 SYNOPSIS

    use Bivio::Biz::Action::InstrumentBuy;
    Bivio::Biz::Action::InstrumentBuy->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::InstrumentBuy::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::InstrumentBuy>

=cut

#=IMPORTS
use Bivio::Biz::PropertyModel::Entry;
use Bivio::Biz::PropertyModel::RealmAccountEntry;
use Bivio::Biz::PropertyModel::RealmInstrumentEntry;
use Bivio::Biz::PropertyModel::RealmTransaction;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Creates all the transactions entries associated with purchasing an
instrument.

Required Request attributes:

  realm_instrument_id
  date
  shares
  cash_account_id
  total_price
  commission
  service_charge
  remark

=cut

sub execute {
    my(undef, $req) = @_;

    my($realm_instrument_id, $date, $shares, $cash_account_id, $total_price,
	    $commission, $service_charge, $remark)
	    = $req->get('realm_instrument_id', 'date', 'shares',
		    'cash_account_id', 'total_price', 'commission',
		    'service_charge', 'remark');
    my($transaction) = Bivio::Biz::PropertyModel::RealmTransaction->new($req);
    $transaction->create({
	realm_id => $req->get('auth_id'),
	source_class => Bivio::Type::EntryClass::INSTRUMENT(),
	dttm => $date,
	user_id => $req->get('auth_user')->get('realm_id'),
	remark => $remark,
    });

    # cash entry
    my($entry) = Bivio::Biz::PropertyModel::Entry->new($req);
    $entry->create({
	realm_transaction_id => $transaction->get('realm_transaction_id'),
	class => Bivio::Type::EntryClass::CASH(),
	entry_type => Bivio::Type::EntryType::INSTRUMENT_BUY(),
	tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	tax_basis => 1,
	amount => - ($total_price + $commission + $service_charge),
    });
    my($account_entry) = Bivio::Biz::PropertyModel::RealmAccountEntry
	    ->new($req);
    $account_entry->create({
	entry_id => $entry->get('entry_id'),
	realm_account_id => $cash_account_id,
    });

    # calculate next block number
    my($inst) = Bivio::Biz::PropertyModel::RealmInstrument->new($req);
    $inst->load(realm_instrument_id => $realm_instrument_id);
    my($block) = $inst->get_next_block();

    # buy entry
    $entry->create({
	realm_transaction_id => $transaction->get('realm_transaction_id'),
	class => Bivio::Type::EntryClass::INSTRUMENT(),
	entry_type => Bivio::Type::EntryType::INSTRUMENT_BUY(),
	tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	tax_basis => 1,
	amount => - $total_price,
    });
    my($instrument_entry) = Bivio::Biz::PropertyModel::RealmInstrumentEntry
	    ->new($req);
    $instrument_entry->create({
	entry_id => $entry->get('entry_id'),
	realm_instrument_id => $realm_instrument_id,
	count => $req->get('shares'),
	external_identifier => $block,
    });

    # optional commission entry
    if ($commission > 0) {
	$entry->create({
	    realm_transaction_id => $transaction->get('realm_transaction_id'),
	    class => Bivio::Type::EntryClass::INSTRUMENT(),
	    entry_type => Bivio::Type::EntryType::INSTRUMENT_BUY_COMMISSION(),
	    tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	    tax_basis => 1,
	    amount => - $commission,
	});
	$instrument_entry->create({
	    entry_id => $entry->get('entry_id'),
	    realm_instrument_id => $realm_instrument_id,
	    count => 0,
	    external_identifier => $block,
	});
    }

    # optional service charge entry
    if ($service_charge > 0 ) {
	$entry->create({
	    realm_transaction_id => $transaction->get('realm_transaction_id'),
	    class => Bivio::Type::EntryClass::INSTRUMENT(),
	    entry_type => Bivio::Type::EntryType::INSTRUMENT_BUY_FEE(),
	    tax_category => Bivio::Type::TaxCategory::MISC_EXPENSE(),
	    tax_basis => 0,
	    amount => - $service_charge,
	});
	$instrument_entry->create({
	    entry_id => $entry->get('entry_id'),
	    realm_instrument_id => $realm_instrument_id,
	    count => 0,
	    external_identifier => $block,
	});
    }

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
