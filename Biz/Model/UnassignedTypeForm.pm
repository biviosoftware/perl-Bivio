# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UnassignedTypeForm;
use strict;
$Bivio::Biz::Model::UnassignedTypeForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::UnassignedTypeForm::VERSION;

=head1 NAME

Bivio::Biz::Model::UnassignedTypeForm - form for identifying unassigned types

=head1 SYNOPSIS

    use Bivio::Biz::Model::UnassignedTypeForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::UnassignedTypeForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UnassignedTypeForm> form for identifying unassigned types

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::Die;
use Bivio::TypeError;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_T) = 'Bivio::Type::EntryType';
my($_TASK_MAP) = {
    $_T->MEMBER_PAYMENT->get_name => 'CLUB_ACCOUNTING_MEMBER_PAYMENT',
    $_T->MEMBER_PAYMENT_FEE->get_name => 'CLUB_ACCOUNTING_MEMBER_FEE',
    $_T->CASH_INCOME->get_name => 'CLUB_ACCOUNTING_ACCOUNT_INCOME',
    $_T->CASH_TRANSFER->get_name => 'CLUB_ACCOUNTING_ACCOUNT_TRANSFER',
    $_T->CASH_EXPENSE->get_name => 'CLUB_ACCOUNTING_ACCOUNT_EXPENSE',
    $_T->MEMBER_MULTIPLE_PAYMENT->get_name => 'CLUB_ACCOUNTING_PAYMENT',
    $_T->MEMBER_MULTIPLE_PAYMENT_FEE->get_name => 'CLUB_ACCOUNTING_FEE',
    $_T->MEMBER_GENERAL_WITHDRAWAL->get_name =>
            'CLUB_ACCOUNTING_MEMBER_WITHDRAWAL',
};

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Redirects to the appropriate form for editing the unassigned transaction.

=cut

sub execute_ok {
    my($self) = @_;

    Bivio::Biz::Model->new($self->get_request, 'RealmTransaction')->load(
	    realm_transaction_id => $self->get(
		    'RealmTransaction.realm_transaction_id'));

    my($task_name) = $_TASK_MAP->{$self->get('Entry.entry_type')->get_name};

    unless ($task_name) {
	Bivio::IO::Alert->warn("unknown task for type ",
		$self->get('Entry.entry_type'));
	return;
    }

    $self->get_request->server_redirect(Bivio::Agent::TaskId->$task_name());

    # DOES NOT RETURN
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	visible => [
	    {
		name => 'Entry.entry_type',
		constraint => 'NONE',
	    },
	],
	hidden => [
	    {
		name => 'RealmTransaction.realm_transaction_id',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="set_fields"></a>

=head2 set_fields(string entry_type, string txn_id)

Saves the specified entry type and transaction id and revalidates the form.

=cut

sub set_fields {
    my($self, $entry_type, $txn_id) = @_;
    $self->internal_put_field('Entry.entry_type' => $entry_type);
    $self->internal_put_field('RealmTransaction.realm_transaction_id' =>
	    $txn_id);
    $self->clear_errors;
    $self->validate;
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Ensures that the type isn't 'unassigned'.

=cut

sub validate {
    my($self) = @_;

    $self->internal_put_error('Entry.entry_type',
	    Bivio::TypeError::SELECT_VALID_CREDIT_TYPE())
	    if $self->get('Entry.entry_type')
		    == Bivio::Type::EntryType::CASH_UNASSIGNED_CREDIT();

    $self->internal_put_error('Entry.entry_type',
	    Bivio::TypeError::SELECT_VALID_DEBIT_TYPE())
	    if $self->get('Entry.entry_type')
		    == Bivio::Type::EntryType::CASH_UNASSIGNED_DEBIT();
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
