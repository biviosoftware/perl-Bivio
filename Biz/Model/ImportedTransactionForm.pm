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

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets the default selected row.

=cut

sub execute_empty {
    my($self) = @_;

    # get the type and selected row from the ImportedTransactionTypeForm
    # from the previous task

    my($type_form) = $self->get_request->get(
	    'Bivio::Biz::Model::ImportedTransactionTypeForm');
    $self->internal_put_field(selected_row =>
	    $type_form->get('selected_row'));

    $self->copy_list_fields;

    $self->internal_put_field('Entry.entry_type' =>
	    $type_form->get('Entry.entry_type'));
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Creates a member deposit transaction with entries for member and account.

=cut

sub execute_ok {
    my($self) = @_;

    my($type) = $self->get('Entry.entry_type');
    if ($type == $type->CASH_INCOME()) {
	_execute_income($self);
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

    # tag new transaction with account synch key
    _tag_sync_key($self);

    # and create new transaction for any excess
    _create_excess_transaction($self);

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
	    name => 'target_account_id',
	    type => 'PrimaryId',
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

# _create_excess_transaction()
#
# Creates a new transaction, if the amount didn't comsume the entire
# amount.
#
sub _create_excess_transaction {
    my($self) = @_;
    my($txn) = Bivio::Biz::Model::RealmTransaction->new($self->get_request)
	    ->load(realm_transaction_id =>
		    $self->get_list_field(
			    'RealmTransaction.realm_transaction_id'));
    my($entry) = Bivio::Biz::Model::Entry->new($self->get_request)
	    ->load(realm_transaction_id =>
		    $txn->get('realm_transaction_id'),
		    class => Bivio::Type::EntryClass::CASH());

    my($remainder) = $_M->sub($entry->get('amount'),
	    $self->get('Entry.amount'));

    if ($_M->compare($remainder, 0) > 0) {
	# save any excess
	$entry->update({amount => $remainder});
    }
    else {
	# otherwise delete the old transaction
	$txn->cascade_delete;
    }
    return;
}

# _execute_income()
#
# Creates an income entry.
#
sub _execute_income {
    my($self) = @_;

    my($values) = {
	%{$self->internal_get},
	'ExpenseInfo.allocate_equally' => undef,
	'ExpenseCategory.expense_category_id' => undef,
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
#TODO: need a way to allow the user to specify this
	'MemberEntry.valuation_date' => $self->get(
		'RealmTransaction.date_time'),
	'RealmAccountEntry.realm_account_id' => $self->get(
		'RealmAccount.realm_account_id'),
    };

#TODO: need a better way to do this
    # load the target realm owner
    my($realm) = Bivio::Biz::Model::RealmOwner->new($self->get_request);
    $realm->unauth_load_or_die(realm_id => $self->get('MemberEntry.user_id'));
    # make sure they are in the club
    my($user_list) = $self->get_request->get(
	    'Bivio::Biz::Model::RealmUserList');
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
	source_account_id => $self->get('RealmAccount.realm_account_id'),
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

# _get_selected_transaction() : Bivio::Biz::Model::RealmTransaction
#
# Returns the transaction currently being edited.
#
sub _get_selected_transaction {
    my($self) = @_;
    return $self->get_request->get('Bivio::Biz::Model::RealmTransaction');
}

# _tag_sync_key()
#
# Tags the current transaction with the selected account sync key.
#
sub _tag_sync_key {
    my($self) = @_;

    Bivio::Biz::Model::AccountSync->new($self->get_request)->create({
	realm_transaction_id => _get_selected_transaction($self)->get(
		'realm_transaction_id'),
	realm_id => $self->get_request->get('auth_id'),
	sync_key => $self->get_list_field('AccountSync.sync_key'),
    });
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
