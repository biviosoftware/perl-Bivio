# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AccountOpenBalanceForm;
use strict;
$Bivio::Biz::Model::AccountOpenBalanceForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::AccountOpenBalanceForm - Open account balance entry

=head1 SYNOPSIS

    use Bivio::Biz::Model::AccountOpenBalanceForm;
    Bivio::Biz::Model::AccountOpenBalanceForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AccountOpenBalanceForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AccountOpenBalanceForm> opening account balance entry

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK : string

Returns OK button value.

May be overriden.

=cut

sub SUBMIT_OK {
    return ' Next ';
}

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::AccountOpenBalanceList;
use Bivio::Biz::Model::RealmAccount;
use Bivio::Biz::Model::RealmAccountEntry;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::Biz::Model::RealmTransactionList;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

# maps field names to default account names
my($_ACCOUNT_FIELD_MAP) = {
    bank => Bivio::Biz::Model::RealmAccount::BANK(),
    broker => Bivio::Biz::Model::RealmAccount::BROKER(),
    petty_cash => Bivio::Biz::Model::RealmAccount::PETTY_CASH(),
    suspense => Bivio::Biz::Model::RealmAccount::SUSPENSE(),
};

my($_ACCOUNT_NAME_MAP) = {
    Bivio::Biz::Model::RealmAccount::BANK() => 'bank',
    Bivio::Biz::Model::RealmAccount::BROKER() => 'broker',
    Bivio::Biz::Model::RealmAccount::PETTY_CASH() => 'petty_cash',
    Bivio::Biz::Model::RealmAccount::SUSPENSE() => 'suspense',
};

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets default fields

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    # default the date to the start of this tax year
    $properties->{'RealmTransaction.date_time'} = Bivio::Biz::Accounting::Tax
	    ->get_this_fiscal_year;

    # get the existing opening balances
    my($list) = Bivio::Biz::Model::AccountOpenBalanceList->new($req);
    $list->load_all;
    while ($list->next_row) {
	my($name, $amount, $date) = $list->get(
		qw(RealmAccount.name Entry.amount RealmTransaction.date_time));
	$properties->{$_ACCOUNT_NAME_MAP->{$name}} = $amount || 0;
	$properties->{'RealmTransaction.date_time'} = $date;
    }
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Creates opening balance entries for each account.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request();
    my($realm) = $req->get('auth_realm')->get('owner');
    my($properties) = $self->internal_get();

    # delete all existing account opening balances
    my($txn) = Bivio::Biz::Model::RealmTransaction->new($req);
    my($txn_list) = Bivio::Biz::Model::RealmTransactionList->new($req);
    $req->put($txn_list->ENTRY_TYPE_FILTER =>
	    Bivio::Type::EntryType::CASH_OPENING_BALANCE());
    $txn_list->load_all;
    while ($txn_list->next_row) {
	$txn->load(realm_transaction_id => $txn_list->get(
		'RealmTransaction.realm_transaction_id'));
	$txn->cascade_delete;
    }

    # create the transaction
    $txn->create({
	source_class => Bivio::Type::EntryClass::CASH(),
	date_time => $properties->{'RealmTransaction.date_time'},
    });

    # iterate account fields, load the associated RealmAccount
    # and create an entry for it
    my($account) = Bivio::Biz::Model::RealmAccount->new($req);
    my($account_entry) = Bivio::Biz::Model::RealmAccountEntry->new($req);
    foreach my $field ('bank', 'broker', 'petty_cash', 'suspense') {
	my($balance) = Bivio::Type::Amount->round(
		$properties->{$field} || 0, 2);

	# create entries even if balance is 0
	if ($field eq 'petty_cash') {
	    $account->unsafe_load(name => $_ACCOUNT_FIELD_MAP->{$field})
		    || next;
	}
	else {
	    $account->load(name => $_ACCOUNT_FIELD_MAP->{$field});
	}
	$account_entry->create_entry($txn, {
	    realm_account_id => $account->get('realm_account_id'),
	    entry_type => Bivio::Type::EntryType::CASH_OPENING_BALANCE(),
	    amount => $balance,
	    # doesn't affect club's tax basis if account is part of valuation
	    tax_basis => $account->get('in_valuation'),
	});
    }

    # need to update units after this date
    $realm->audit_units($properties->{'RealmTransaction.date_time'});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	require_context => 1,
	visible => [
	    {
		name => 'RealmTransaction.date_time',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'bank',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'broker',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'petty_cash',
		type => 'Amount',
		constraint => 'NONE',
	    },
	    {
		name => 'suspense',
		type => 'Amount',
		constraint => 'NONE',
	    },
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id',
	        'Entry.realm_id'],
	primary_key => [
	    ['RealmTransaction.realm_transaction_id',
		     'Entry.realm_transaction_id']
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Validates form fields.

=cut

sub validate {
    my($self) = @_;

    # amounts can be negative

    # check that the year is not over the fiscal boundary
    my($date) = $self->get('RealmTransaction.date_time');
    if ($date && Bivio::Type::Date->compare($date,
	    Bivio::Biz::Accounting::Tax->get_this_fiscal_year) > 0) {

	$self->internal_put_error('RealmTransaction.date_time',
		Bivio::TypeError::INVALID_OPENING_BALANCE_DATE())
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
