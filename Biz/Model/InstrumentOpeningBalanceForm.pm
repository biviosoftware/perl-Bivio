# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentOpeningBalanceForm;
use strict;
$Bivio::Biz::Model::InstrumentOpeningBalanceForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InstrumentOpeningBalanceForm - record an investment opening balance

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentOpeningBalanceForm;
    Bivio::Biz::Model::InstrumentOpeningBalanceForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InstrumentOpeningBalanceForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentOpeningBalanceForm> record an investment
opening balance.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::Instrument;
use Bivio::Biz::Model::InstrumentLookupForm;
use Bivio::Biz::Model::InstrumentLookupList;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::Biz::Model::RealmInstrumentEntry;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;
use Bivio::Type::EntryClass;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Initializes the empty form.

=cut

sub execute_empty {
    my($self) = @_;
    $self->internal_get->{
	Bivio::Biz::Model::InstrumentLookupList::SHOW_LOCAL()} = 1;
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Record and investment opening balance.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get();
    my($req) = $self->get_request();
    my($realm) = $req->get('auth_realm')->get('owner');

    # load the realm instrument associated with the ticker
    my($ticker) = $properties->{'Instrument.ticker_symbol'};
    my($realm_inst) = Bivio::Biz::Model::RealmInstrument->new($req);
    unless ($realm_inst->unsafe_find_or_create($ticker)) {
	$self->internal_put_error('Instrument.ticker_symbol',
		Bivio::TypeError::NOT_FOUND());
	return;
    }

    # create the transaction
    my($transaction) = Bivio::Biz::Model::RealmTransaction->new($req);
    $transaction->create({
	realm_id => $realm->get('realm_id'),
	source_class => Bivio::Type::EntryClass::INSTRUMENT(),
	date_time => $properties->{'RealmTransaction.date_time'},
	user_id => $req->get('auth_user')->get('realm_id'),
	remark => $properties->{'RealmTransaction.remark'},
    });

    # opening balance entry
    my($inst_entry) = Bivio::Biz::Model::RealmInstrumentEntry->new($req);
    $inst_entry->create_entry($transaction, {
	entry_type => Bivio::Type::EntryType::INSTRUMENT_OPENING_BALANCE(),
	realm_instrument_id => $realm_inst->get('realm_instrument_id'),
	amount => $properties->{'paid'},
	tax_category => Bivio::Type::TaxCategory::NOT_TAXABLE(),
	tax_basis => 1,
	count => $properties->{'RealmInstrumentEntry.count'},
	# use the transaction id to identify this block
	external_identifier => $transaction->get('realm_transaction_id'),
    });
    # need to update units after this date
    $realm->audit_units($properties->{'RealmTransaction.date_time'});
    return;
}

=for html <a name="execute_other"></a>

=head2 execute_other(string button)

Resonds to selecting a non-OK button.

=cut

sub execute_other {
    my($self, $button) = @_;

    # redirect to the lookup form
    $self->get_request->server_redirect(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_INVESTMENT_LOOKUP())
      if ($button eq Bivio::Biz::Model::InstrumentLookupForm::SYMBOL_LOOKUP());

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
	    'Instrument.ticker_symbol',
	    {
		name => 'paid',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    'RealmInstrumentEntry.count',
	    'RealmTransaction.remark'
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id',
	        'Entry.realm_id'],
	primary_key => [
	    ['RealmTransaction.realm_transaction_id',
		     'Entry.realm_transaction_id']
	],
	hidden => [
	    {
		name => Bivio::Biz::Model::InstrumentLookupList::SHOW_LOCAL(),
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Validates field values.

=cut

sub validate {
    my($self) = @_;

    $self->validate_not_null('Instrument.ticker_symbol');
    $self->validate_not_negative('paid');
    $self->validate_greater_than_zero('RealmInstrumentEntry.count');

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
