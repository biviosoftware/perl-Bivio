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
	    $self->get_request->get(
		    'Bivio::Biz::Model::RealmValuationAccountList')
		    ->get_default_broker_account();
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()


=cut

sub execute_input {
    my($self) = @_;

    # need to convert date to display value, or next form will barf
    my($properties) = $self->internal_get;
#TODO: Need a better way of passing info in forms
    $self->get_request->get('form')->{'RealmTransaction.date_time'}
	    = Bivio::Type::Date->to_literal(
		    $properties->{'RealmTransaction.date_time'});

    _fill_lots_fifo($self);

    # hacked redirect to page two
    $self->get_request->get('form')->{stay_on_page} = 1;
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

    my($properties) = $self->internal_get;

    # amount can be zero for a worthless investment
    $self->validate_not_negative('Entry.amount');
    $self->validate_greater_than_zero('RealmInstrumentEntry.count');

    # don't validate shares owned unless the date is valid
    my($date) = $properties->{'RealmTransaction.date_time'};
    if (defined($date)) {
	my($req) = $self->get_request;
	my($realm) = $req->get('auth_realm')->get('owner');
	my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');
	my($shares_owned) = $realm->get_number_of_shares($date)
		->{$realm_inst->get('realm_instrument_id')};
	# number of shares shouldn't exceed owned
	$self->internal_put_error('RealmInstrumentEntry.count',
		Bivio::TypeError::SHARES_SOLD_EXCEEDS_OWNED())
		unless !defined($properties->{'RealmInstrumentEntry.count'})
			|| $properties->{'RealmInstrumentEntry.count'}
				<= $shares_owned;
    }
    return;
}

#=PRIVATE METHODS

# _fill_lots_fifo()
#
# Loads the lot fields with values using first-in-first-out.
#
sub _fill_lots_fifo {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
    my($count) = $properties->{'RealmInstrumentEntry.count'};

    my($lot_list) = Bivio::Biz::Model::RealmInstrumentLotList->new($req);
    $lot_list->load();
    my($lot_num) = 0;

    while ($lot_list->next_row) {
	my($quantity) = $lot_list->get('quantity');

	if ($quantity >= $count) {
	    $req->get('form')->{'lot'.$lot_num} =
		    Bivio::Type::Amount->to_literal($count);
	    last;
	}
	else {
	    $req->get('form')->{'lot'.$lot_num} =
		    Bivio::Type::Amount->to_literal($quantity);
	    $count = Bivio::Type::Amount->sub($count, $quantity);
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
