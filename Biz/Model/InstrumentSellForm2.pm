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
my($_MAY_7_1997) = Bivio::Type::Date->date_from_parts(7, 5, 1997);


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

    my($total_amount) = Bivio::Type::Amount->sub(
	    $properties->{'Entry.amount'}, $properties->{commission});
    my($shares) = $properties->{'RealmInstrumentEntry.count'};
    # value of the share at sale including commission
    my($share_value) = Bivio::Type::Amount->div(
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
	    amount => Bivio::Type::Amount->neg($properties->{commission}),
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

    Bivio::Biz::Model::RealmInstrumentValuation->create_or_update(
	    $realm_inst_id,
	    $properties->{'RealmTransaction.date_time'},
	    Bivio::Type::Amount->div($properties->{'Entry.amount'}, $shares));

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
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    'RealmAccountEntry.realm_account_id',
	    'RealmInstrumentEntry.count',
	    'Entry.amount',
	    {
		name => 'commission',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
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

    my($data) = $self->get_request->get('form') || {};
    my($lot_list) =$self->get_request->get(
	    'Bivio::Biz::Model::RealmInstrumentLotList');
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
	my($v, $err) = Bivio::Type::Amount->from_literal($value);
	if (defined($v)) {
	    if ($v < 0) {
		$err = Bivio::TypeError::GREATER_THAN_ZERO();
	    }
	    elsif ($v > $quantity->[$i]) {
		$err = Bivio::TypeError::GREATER_THAN_QUANTITY();
	    }
	    else {
		$sum = Bivio::Type::Amount->add($sum, $v);
	    }
	}
	if (defined($err)) {
	    $self->internal_put_error($name, $err);
	}
    }
    my($properties) = $self->internal_get;
    unless ($self->in_error) {

	if ($self->get_request->get('form')->{stay_on_page}) {
	    # see overridden in_error()
	    $self->internal_put_error(stay_on_page =>
		    Bivio::TypeError::UNKNOWN());
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
	    amount => $fields->{$type},
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
    my($cost_basis) = Bivio::Type::Amount->mul(
	    $lot_list->get('cost_per_share'), $amount);
    my($inst_entry) = Bivio::Biz::Model::RealmInstrumentEntry->new(
	    $self->get_request);
    $inst_entry->create_entry($transaction, {
	entry_type => Bivio::Type::EntryType::INSTRUMENT_SELL(),
	realm_instrument_id => $id,
	amount => Bivio::Type::Amount->neg($cost_basis),
	tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	tax_basis => 1,
	count => Bivio::Type::Amount->neg($amount),
	external_identifier => $lot_list->get('lot'),
    });

    # gain
    my($gain) = Bivio::Type::Amount->sub(
	    Bivio::Type::Amount->mul($amount, $share_value),
	    $cost_basis);
    my($gain_type) = _determine_gain_type($lot_list->get('purchase_date'),
	    $transaction->get('date_time'));
    $fields->{$gain_type} = Bivio::Type::Amount->add($fields->{$gain_type},
	    $gain);
    return;
}

# _determine_gain_type(string purchase_date, string sell_date) : Bivio::Type::TaxCategory
#
# Returns the appropriate tax type for the instrument held between the two
# dates.
#
# if days <= 1 year then STCG
# else if sell in 1997 and (before may 7 or held <= 18 months) MTCG
# otherwise LTCG
#
sub _determine_gain_type {
    my($purchase_date, $sell_date) = @_;

    # This is literal days.  It doesn't matter what time.
    my($days) = Bivio::Type::Date->get_days_between($purchase_date,
	    $sell_date);
#TODO: handle leap year
    if ($days <= 365) {
	return 'stcg';
    }
    my(@parts) = Bivio::Type::DateTime->to_parts($sell_date);
    my($sell_year) = $parts[5];
    if ($sell_year == 1997) {
	if (Bivio::Type::DateTime->compare($_MAY_7_1997, $sell_date)) {
	    return 'mtcg';
	}
#TODO; need to determine 18 months holding
	if ($days < 18 * 30) {
	    return 'mtcg';
	}
    }
    return 'ltcg';
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
