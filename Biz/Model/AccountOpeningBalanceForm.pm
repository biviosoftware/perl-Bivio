# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AccountOpeningBalanceForm;
use strict;
$Bivio::Biz::Model::AccountOpeningBalanceForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::AccountOpeningBalanceForm - opening account balance entry

=head1 SYNOPSIS

    use Bivio::Biz::Model::AccountOpeningBalanceForm;
    Bivio::Biz::Model::AccountOpeningBalanceForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AccountOpeningBalanceForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AccountOpeningBalanceForm> opening account balance entry

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::RealmAccount;
use Bivio::Biz::Model::RealmAccountEntry;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::SQL::Constraint;
use Bivio::TypeError;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

# maps field names to default account names
my($_ACCOUNT_MAP) = {
    bank => Bivio::Biz::Model::RealmAccount::BANK(),
    broker => Bivio::Biz::Model::RealmAccount::BROKER(),
    petty_cash => Bivio::Biz::Model::RealmAccount::PETTY_CASH(),
    suspense => Bivio::Biz::Model::RealmAccount::SUSPENSE(),
};

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets default fields

=cut

sub execute_empty {
    my($self) = @_;
    my($properties) = $self->internal_get;

    # default the date to the start of this tax year
    $properties->{'RealmTransaction.date_time'} = Bivio::Biz::Accounting::Tax
	    ->get_this_fiscal_year;
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

    # create the transaction
    my($transaction) = Bivio::Biz::Model::RealmTransaction->new($req);
    $transaction->create({
	realm_id => $realm->get('realm_id'),
	source_class => Bivio::Type::EntryClass::CASH(),
	date_time => $properties->{'RealmTransaction.date_time'},
	user_id => $req->get('auth_user')->get('realm_id'),
	remark => $properties->{'RealmTransaction.remark'},
    });

    # iterate account fields, load the associated RealmAccount
    # and create an entry for it
    my($account) = Bivio::Biz::Model::RealmAccount->new($req);
    my($account_entry) = Bivio::Biz::Model::RealmAccountEntry->new($req);
    foreach my $field ('bank', 'broker', 'petty_cash', 'suspense') {
	my($balance) = Bivio::Type::Amount->round(
		$properties->{$field} || 0, 2);
	next if $balance == 0;

	$account->load(name => $_ACCOUNT_MAP->{$field});
	$account_entry->create_entry($transaction, {
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
	visible => [
	    {
		name => 'RealmTransaction.date_time',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    {
		name => 'bank',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
		name => 'broker',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
		name => 'petty_cash',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
		name => 'suspense',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
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
