# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSellForm;
use strict;
$Bivio::Biz::Model::InstrumentSellForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InstrumentSellForm - process an instrument sell form

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSellForm;
    Bivio::Biz::Model::InstrumentSellForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentSellForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSellForm>

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmInstrumentLotList;
use Bivio::IO::Trace;
use Bivio::TypeError;
use Bivio::UI::HTML::Format::Date;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($math) = 'Bivio::Type::Amount';

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Processes an empty form.

=cut

sub execute_empty {
    my($self) = @_;
    my($properties) = $self->internal_get;
    # default account to Broker
    $properties->{'RealmAccountEntry.realm_account_id'} =
	    $self->get_request->get('Bivio::Biz::Model::RealmAccountList')
		    ->get_default_broker_account();
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()


=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;

    # need to convert date to display value, or next form will barf
    my($properties) = $self->internal_get;
    my($date) = $properties->{'RealmTransaction.date_time'};
#TODO: Need a better way of passing info in forms
    $req->get('form')->{'RealmTransaction.date_time'}
	    = Bivio::Type::Date->to_literal($date);

    my($inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
    if ($inst->get('average_cost_method')) {
	_fill_lots_average_cost($self, $date);
    }
    else {
	_fill_lots_fifo($self, $date);
    }

    # hacked redirect to page two
    $req->get('form')->{stay_on_page} = 1;
    $self->internal_put_error(redirect => Bivio::TypeError::UNKNOWN);

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
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

    my($properties) = $self->internal_get;

    # amount can be zero for a worthless investment
    $self->validate_not_negative('Entry.amount');
    $self->validate_greater_than_zero('RealmInstrumentEntry.count');

    # don't validate shares owned unless the date is valid
    my($date) = $properties->{'RealmTransaction.date_time'};
    my($count) = $properties->{'RealmInstrumentEntry.count'};

    if (defined($date) && defined($count)) {
	my($req) = $self->get_request;
	my($realm) = $req->get('auth_realm')->get('owner');
	my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
	my($shares_owned) = $realm->get_number_of_shares($date)
		->{$realm_inst->get('realm_instrument_id')} || 0;
	# number of shares shouldn't exceed owned
	$self->internal_put_error('RealmInstrumentEntry.count',
		Bivio::TypeError::SHARES_SOLD_EXCEEDS_OWNED())
		unless $count <= $shares_owned;
    }
    return;
}

#=PRIVATE METHODS

# _fill_lots_average_cost(string date)
#
# Loads lot fields using and average cost algorithm.
#
sub _fill_lots_average_cost {
    my($self, $date) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
    my($count) = $properties->{'RealmInstrumentEntry.count'};

    my($lot_list) = Bivio::Biz::Model::RealmInstrumentLotList->new($req);
    $req->put(Bivio::Biz::Model::RealmInstrumentLotList::DATE_QUERY()
	    => $date);
    $lot_list->load();
    my($lot_num) = 0;
    my($form) = $req->get('form');

    my($total) = 0;
    while ($lot_list->next_row) {
	$total = $math->add($total, $lot_list->get('quantity'));
    }

    # if selling all shares, use fifo
    if ($math->compare($count, $total) == 0) {
	_fill_lots_fifo($self, $date);
	return;
    }

    my($total_dist) = 0;
    $lot_list->reset_cursor;
    while ($lot_list->next_row) {
	my($quantity) = $lot_list->get('quantity');

	my($dist) = $math->div($math->mul($quantity, $count), $total);
	$form->{'lot'.$lot_num} = $math->to_literal($dist);
	$total_dist = $math->add($total_dist, $dist);
	$lot_num++;
    }
    # adjust last lot with difference between count and total_dist
    if ($math->compare($total_dist, $count) != 0) {
	my($adjustment) = $math->sub($count, $total_dist);
	my($last_lot) = $lot_list->get_result_set_size - 1;
	$form->{'lot'.$last_lot} = $math->to_literal(
		$math->add($form->{'lot'.$last_lot}, $adjustment));
    }
    return;
}

# _fill_lots_fifo(string date)
#
# Loads the lot fields with values using first-in-first-out.
#
sub _fill_lots_fifo {
    my($self, $date) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
    my($count) = $properties->{'RealmInstrumentEntry.count'};

    my($lot_list) = Bivio::Biz::Model::RealmInstrumentLotList->new($req);
    $req->put(Bivio::Biz::Model::RealmInstrumentLotList::DATE_QUERY()
	    => $date);
    $lot_list->load();
    my($lot_num) = 0;
    my($form) = $req->get('form');

    while ($lot_list->next_row) {
	my($quantity) = $lot_list->get('quantity');

	if ($quantity >= $count) {
	    $form->{'lot'.$lot_num} = $math->to_literal($count);
	    last;
	}
	else {
	    $form->{'lot'.$lot_num} = $math->to_literal($quantity);
	    $count = $math->sub($count, $quantity);
	}
	$lot_num++;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
