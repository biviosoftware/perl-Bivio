# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSellForm2;
use strict;
$Bivio::Biz::Model::InstrumentSellForm2::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InstrumentSellForm2 - second part of instrument sell

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSellForm2;
    Bivio::Biz::Model::InstrumentSellForm2->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentSellForm2::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSellForm2> is the second part of instrument
sell. Shows a lot list and fills values FIFO.

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmAccountEntry;
use Bivio::Biz::Model::RealmInstrumentEntry;
use Bivio::Biz::Model::RealmInstrumentLotList;
use Bivio::Biz::Model::RealmInstrumentValuation;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::IO::Trace;
use Bivio::SQL::Constraint;
use Bivio::TypeError;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($math) = 'Bivio::Type::Amount';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::InstrumentBuyForm

Creates an instrument buy form.

=cut

sub new {
    my($self) = &Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {
	stcg => 0,
	mtcg => 0,
	ltcg => 0,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Creates the transaction with entries for commission, account entry,
instrument cost basis and gain.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request();
    my($properties) = $self->internal_get();
    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
    my($realm_inst_id) = $realm_inst->get('realm_instrument_id');

    my($total_amount) = $math->sub(
	    $properties->{'Entry.amount'}, $properties->{commission} || 0);
    my($shares) = $properties->{'RealmInstrumentEntry.count'};
    # value of the share at sale including commission
    my($share_value) = $math->div(
	    $total_amount, $properties->{'RealmInstrumentEntry.count'});

    # create the transaction
    my($transaction) = Bivio::Biz::Model::RealmTransaction->new($req);
    $transaction->create({
	source_class => Bivio::Type::EntryClass::INSTRUMENT(),
	date_time => $properties->{'RealmTransaction.date_time'},
	remark => $properties->{'RealmTransaction.remark'},
    });

    # sale commission, not part of tax basis
    if (defined($properties->{commission}) && $properties->{commission} > 0) {
	my($inst_entry) = Bivio::Biz::Model::RealmInstrumentEntry->new($req);
	$inst_entry->create_entry($transaction, {
	    entry_type =>
	    Bivio::Type::EntryType::INSTRUMENT_SELL_COMMISSION_AND_FEE(),
	    realm_instrument_id => $realm_inst_id,
	    amount => $math->neg($properties->{commission}),
	    tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	});
    }

    # account entry
    my($account_entry) = Bivio::Biz::Model::RealmAccountEntry->new($req);
    $account_entry->create_entry($transaction, {
	entry_type => Bivio::Type::EntryType::INSTRUMENT_SELL(),
	realm_account_id => $properties->{
	    'RealmAccountEntry.realm_account_id'},
	amount => $total_amount,
    });

    # lot sale and gain
    my($data) = $self->get_request->get('form') || {};
    my($lot_list) =$self->get_request->get(
	    'Bivio::Biz::Model::RealmInstrumentLotList');
    my($count) = 0;

    while ($lot_list->next_row) {
	my($amount) = $data->{'lot'.$count++};
	if ($amount) {
	    _create_sell_entry($self, $realm_inst_id,
		    $transaction, $lot_list, $amount, $share_value);
	}
    }
    $lot_list->reset_cursor;
    _create_gain_entries($self, $realm_inst_id, $transaction);

    if ($realm_inst->is_local) {
	Bivio::Biz::Model::RealmInstrumentValuation->create_or_update(
		$realm_inst_id,
		$properties->{'RealmTransaction.date_time'},
		$math->div($properties->{'Entry.amount'}, $shares));
    }

    # need to update units after this date
    my($realm) = $req->get('auth_realm')->get('owner');
    $realm->audit_units($properties->{'RealmTransaction.date_time'});

    return;
}

=for html <a name="get_field_as_html"></a>

=head2 get_field_as_html(string name) : string

Overrides get_field_as_html to handle stock lots.

=cut

sub get_field_as_html {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($name =~ /^lot(.*)$/) {
	my($index) = $1;
	return $fields->{lots}->[$index];
    }
    return $self->SUPER::get_field_as_html($name);
}

=for html <a name="get_field_name_for_html"></a>

=head2 get_field_name_for_html(string name) : string

Overrides get_field_name_for_html to handle stock lots.

=cut

sub get_field_name_for_html {
    my($self, $name) = @_;
    if ($name =~ /^lot(.*)$/) {
	return $name;
    }
    return $self->SUPER::get_field_name_for_html($name);
}

=for html <a name="get_field_type"></a>

=head2 get_field_type(string name) : Bivio::Type

Overrides get_field_type to handle stock lots.

=cut

sub get_field_type {
    my($self, $name) = @_;
    if ($name =~ /^lot(.*)$/) {
	return 'Bivio::Type::Amount';
    }
    return $self->SUPER::get_field_type($name);
}

=for html <a name="in_error"></a>

=head2 in_error() : boolean

Overrides in_error to stay on this page after the internal redirect.
hack

=cut

sub in_error {
    my($self) = @_;
    my($errors) = $self->get_errors;
    if ($errors && $errors->{stay_on_page}) {
	return 0;
    }
    return $self->SUPER::in_error;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	hidden => [
	    {
		name => 'RealmTransaction.date_time',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    'RealmAccountEntry.realm_account_id',
	    'RealmInstrumentEntry.count',
	    'Entry.amount',
	    {
		name => 'commission',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    'RealmTransaction.remark',
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
	primary_key => [
	    'RealmTransaction.realm_transaction_id',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;

    my($data) = $req->get('form') || {};
    my($lot_list) = $req->unsafe_get(
	    'Bivio::Biz::Model::RealmInstrumentLotList');
    unless ($lot_list) {
	$lot_list = Bivio::Biz::Model::RealmInstrumentLotList->new($req);
	$req->put(Bivio::Biz::Model::RealmInstrumentLotList::DATE_QUERY()
		=> $self->get('RealmTransaction.date_time'));
	$lot_list->load();
    }
    $lot_list->reset_cursor;

    my($lot_num) = 0;
    my($lots) = [];
    my($quantity) = [];
    my($count) = 0;
    while ($lot_list->next_row) {
	push(@$lots, $data->{'lot'.$count++} ||'');
	push(@$quantity, $lot_list->get('quantity'));
    }
    $fields->{lots} = $lots;
    $lot_list->reset_cursor;
    my($size) = $lot_list->get_result_set_size;

    # iterate lots, validate each and calculate sum
    my($sum) = 0;
    for (my($i) = 0; $i < $size; $i++) {
	my($name) = 'lot'.$i;
	my($value) = $data->{$name} || 0;
	my($v, $err) = $math->from_literal($value);
	if (defined($v)) {
	    if ($v < 0) {
		$err = Bivio::TypeError::GREATER_THAN_ZERO();
	    }
	    elsif ($v > $quantity->[$i]) {
		$err = Bivio::TypeError::GREATER_THAN_QUANTITY();
	    }
	    else {
		$sum = $math->add($sum, $v);
	    }
	}
	if (defined($err)) {
	    $self->internal_put_error($name, $err);
	}
    }
    my($properties) = $self->internal_get;
    unless ($self->in_error) {

	if ($self->get_request->get('form')->{stay_on_page}) {

	    # automatically advance if there is only one lot, or if
	    # the 'average cost' method is used

	    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
	    unless ($realm_inst->get('average_cost_method')
		    || $lot_list->get_result_set_size == 1) {
		# see overridden in_error()
		$self->internal_put_error(stay_on_page =>
			Bivio::TypeError::UNKNOWN());
	    }
	}
	elsif ($properties->{'RealmInstrumentEntry.count'} != $sum) {
	    $self->internal_put_error('', Bivio::TypeError::INVALID_SUM());
	}
    }
    return;
}

#=PRIVATE METHODS

# _create_gain_entries()
#
# Creates entries for short, medium, and long term capital gains.
#
sub _create_gain_entries {
    my($self, $id, $transaction) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($inst_entry) = Bivio::Biz::Model::RealmInstrumentEntry->new(
	    $self->get_request);

    foreach my $type ('stcg', 'mtcg', 'ltcg') {
	next if $fields->{$type} == 0;

	$inst_entry->create_entry($transaction, {
	    entry_type => Bivio::Type::EntryType::INSTRUMENT_SELL(),
	    realm_instrument_id => $id,
	    amount => $math->round($fields->{$type}, 2),
	    tax_category => $type eq 'stcg'
	        ? Bivio::Type::TaxCategory::SHORT_TERM_CAPITAL_GAIN()
	        : $type eq 'mtcg'
 	            ? Bivio::Type::TaxCategory::MEDIUM_TERM_CAPITAL_GAIN()
	            : Bivio::Type::TaxCategory::LONG_TERM_CAPITAL_GAIN(),
	});
    }

    return;
}

# _create_sell_entry(string id, RealmTransaction transaction, RealmInstrumentLotList lot_list, string amount, string share_value)
#
# Creates transaction entries for the sale and calculates gain.
#
sub _create_sell_entry {
    my($self, $id, $transaction, $lot_list, $amount, $share_value) = @_;
    my($fields) = $self->{$_PACKAGE};

    # cost basis
    my($cost_basis) = $math->mul(
	    $lot_list->get('cost_per_share'), $amount);
    my($inst_entry) = Bivio::Biz::Model::RealmInstrumentEntry->new(
	    $self->get_request);
    $inst_entry->create_entry($transaction, {
	entry_type => Bivio::Type::EntryType::INSTRUMENT_SELL(),
	realm_instrument_id => $id,
	amount => $math->neg($cost_basis),
	tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	tax_basis => 1,
	count => $math->neg($amount),
	external_identifier => $lot_list->get('lot'),
	acquisition_date => $lot_list->get('acquisition_date'),
    });

    # gain
    my($gain) = $math->sub( $math->mul($amount, $share_value),
	    $cost_basis);
    my($gain_type) = lc(Bivio::Biz::Accounting::Tax->get_gain_type(
	    $lot_list->get('acquisition_date'),
	    $transaction->get('date_time'))->get_short_desc);

    $fields->{$gain_type} = $math->add($fields->{$gain_type}, $gain);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
