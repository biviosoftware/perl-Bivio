# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ImportedTransactionForm;
use strict;
$Bivio::Biz::Model::ImportedTransactionForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ImportedTransactionForm::VERSION;

=head1 NAME

Bivio::Biz::Model::ImportedTransactionForm - imported txn editor

=head1 SYNOPSIS

    use Bivio::Biz::Model::ImportedTransactionForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::EditRowFormModel>

=cut

use Bivio::Biz::EditRowFormModel;
@Bivio::Biz::Model::ImportedTransactionForm::ISA = ('Bivio::Biz::EditRowFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ImportedTransactionForm> imported txn editor

=cut

#=IMPORTS
use Bivio::Biz::Model::AccountSync;
use Bivio::Biz::Model::AccountTransactionForm;
use Bivio::Biz::Model::AccountTransferForm;
use Bivio::Biz::Model::Entry;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::Biz::Model::SingleDepositForm;
use Bivio::TypeError;
use Bivio::Type::Amount;
use Bivio::Type::EntryClass;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_M) = 'Bivio::Type::Amount';

=head1 METHODS

=cut

=for html <a name="create_excess_transaction"></a>

=head2 static create_excess_transaction(Bivio::Agent::Request req, string old_txn_id, string amount)

Update the original transaction which keeps the excess between the
previous amount and the new amount.

=cut

sub create_excess_transaction {
    my($proto, $req, $old_txn_id, $amount) = @_;
    my($txn) = Bivio::Biz::Model::RealmTransaction->new($req)
	    ->load(realm_transaction_id => $old_txn_id);
    my($entry) = Bivio::Biz::Model::Entry->new($req)
	    ->load(realm_transaction_id =>
		    $txn->get('realm_transaction_id'),
		    class => Bivio::Type::EntryClass::CASH());

    my($remainder) = $_M->sub($entry->get('amount'), $amount);

    # income
    if ($entry->get('amount') > 0 && $remainder > 0) {
	$entry->update({amount => $remainder});
    }
    # expense
    elsif ($entry->get('amount') < 0 && $remainder < 0) {
	$entry->update({amount => $remainder});
    }
    # otherwise delete the old transaction
    else {
	$txn->cascade_delete;
    }

#    if ($_M->compare($remainder, 0) > 0) {
#	# save any excess
#	$entry->update({amount => $remainder});
#    }
#    else {
#	# otherwise delete the old transaction
#	$txn->cascade_delete;
#    }
    return;
}

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets the default selected row.

=cut

sub execute_empty {
    my($self) = @_;

    # get the type and selected row from the ImportedTransactionTypeForm
    # from the previous task

    my($type_form) = $self->get_request->unsafe_get(
	    'Bivio::Biz::Model::ImportedTransactionTypeForm');

    # the previous state was lost (from changing sort order)
    # return to the original identify page
    unless ($type_form) {
	$self->get_request->client_redirect(
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_SYNC_IDENTIFY());
    }

    $self->internal_put_field(selected_row =>
	    $type_form->get('selected_row'));

    $self->copy_list_fields;

    $self->internal_put_field('Entry.entry_type' =>
	    $type_form->get('Entry.entry_type'));
    $self->internal_put_field('MemberEntry.valuation_date' =>
	    $self->get('RealmTransaction.date_time'));

    $self->internal_put_field('Entry.amount' =>
	    $_M->neg($self->get('Entry.amount')))
	    if $self->get('Entry.entry_type')
		    == Bivio::Type::EntryType::CASH_EXPENSE();

    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Creates a member deposit transaction with entries for member and account.

=cut

sub execute_ok {
    my($self) = @_;

    my($type) = $self->get('Entry.entry_type');
    if ($type == $type->CASH_INCOME()
	   || $type == $type->CASH_EXPENSE) {
	_execute_income_or_expense($self);
    }
    elsif ($type == $type->CASH_TRANSFER()) {
	_execute_transfer($self);
    }
    elsif ($type == $type->MEMBER_PAYMENT()
	   || $type == $type->MEMBER_PAYMENT_FEE) {
	_execute_payment($self);
    }
    else {
	# haven't implemented other types yet...
	return;
    }

    return if $self->in_error;

    # restore the amount sign for expenses
    if ($type == $type->CASH_EXPENSE()) {
	$self->internal_put_field('Entry.amount' =>
		$_M->neg($self->get('Entry.amount')));
    }

    # tag new transaction with account synch key
    $self->tag_transaction($self->get_request,
	    $self->get_list_field('AccountSync.sync_key'),
	    $self->get_list_field('AccountSync.import_date'));

    # and create new transaction for any excess
    $self->create_excess_transaction(
	    $self->get_request,
	    $self->get_list_field('RealmTransaction.realm_transaction_id'),
	    $self->get('Entry.amount'));

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	list_class => 'ImportedTransactionList',
	version => 1,
	visible => [qw(
            Entry.amount
	    MemberEntry.valuation_date
        ),
	{
            name => 'RealmTransaction.remark',
	    in_list => 1,
	},
	{
	    name => 'MemberEntry.user_id',
	    constraint => 'NONE',
	},
	{
	    name => 'source_account_id',
	    type => 'PrimaryId',
	    constraint => 'NONE',
	},
	{
	    name => 'ExpenseCategory.expense_category_id',
	    constraint => 'NONE',
	},
	{
	    name => 'ExpenseInfo.allocate_equally',
	    constraint => 'NONE',
	},
	],
	hidden => [qw(
	    Entry.entry_type
	    RealmTransaction.date_time
            RealmAccount.realm_account_id
	)],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="tag_transaction"></a>

=head2 static tag_transaction(Bivio::Agent::Request req, string sync_key, string import_date)

Tags the current transaction (on the request) with the specified
sync_key.

=cut

sub tag_transaction {
    my($proto, $req, $sync_key, $import_date) = @_;

    Bivio::Biz::Model::AccountSync->new($req)->create({
	realm_transaction_id => $req->get(
		'Bivio::Biz::Model::RealmTransaction')->get(
			'realm_transaction_id'),
	realm_id => $req->get('auth_id'),
	sync_key => $sync_key,
	import_date => $import_date,
    });
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Ensures the fields are valid.

=cut

sub validate {
    my($self) = @_;
    my($amount) = $self->get('Entry.amount');
    $self->internal_put_error('Entry.amount', Bivio::TypeError::NOT_ZERO())
	    if defined($amount) && $amount == 0;
    return;
}

#=PRIVATE METHODS

# _execute_income_or_expense()
#
# Creates an income or expense entry.
#
sub _execute_income_or_expense {
    my($self) = @_;

    my($values) = {
	%{$self->internal_get},
    };

    # load the correct entry type, for the account txn form to use
    $self->get('Entry.entry_type')->execute($self->get_request);
    Bivio::Biz::Model::AccountTransactionForm->execute($self->get_request,
	   $values);
    return;
}

# _execute_payment()
#
# Creates a single member payment.
#
sub _execute_payment {
    my($self) = @_;

    my($values) = {
	%{$self->internal_get},
    };

    if ($self->get('Entry.entry_type')
	    == Bivio::Type::EntryType::MEMBER_PAYMENT()) {
#TODO: copy and pasted from SingleDepositForm
	$self->validate_not_null('MemberEntry.valuation_date');
	my($tran_date, $val_date) = $self->get('RealmTransaction.date_time',
		'MemberEntry.valuation_date');
	if ($val_date && $tran_date
		&& Bivio::Type::Date->compare($val_date, $tran_date) > 0) {
	    $self->internal_put_error('MemberEntry.valuation_date',
		  Bivio::TypeError::VALUATION_DATE_EXCEED_TRANSACTION_DATE());
	}
	return if $self->in_error;
    }

#TODO: need a better way to do this
    # load the target realm owner
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load_or_die(realm_id => $self->get('MemberEntry.user_id'));
    # make sure they are in the club
    my($user_list) = $self->get_request->get(
	    'Bivio::Biz::Model::AllMemberList');
    $user_list->reset_cursor;
    while ($user_list->next_row) {
	next unless $user_list->get('RealmUser.user_id')
		eq $realm->get('realm_id');
	$self->get_request->put(target_realm_owner => $realm);
	last;
    }

    # load the correct entry type, for the payment form to use
    $self->get('Entry.entry_type')->execute($self->get_request);
    Bivio::Biz::Model::SingleDepositForm->execute($self->get_request,
	    $values);
    return;
}

# _execute_transfer()
#
# Creates an account transfer entry.
#
sub _execute_transfer {
    my($self) = @_;

    my($values) = {
	%{$self->internal_get},
	target_account_id => $self->get('RealmAccount.realm_account_id'),
    };

#TODO: need Form->validate
    if ($values->{source_account_id} eq $values->{target_account_id}) {
	# yes, it is odd to put it on the remark - this is the
	# area of the UI the field is displayed
	$self->internal_put_error('RealmTransaction.remark',
		Bivio::TypeError::SOURCE_NOT_EQUAL_TARGET());
	return;
    }
    Bivio::Biz::Model::AccountTransferForm->execute($self->get_request,
	    $values);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
