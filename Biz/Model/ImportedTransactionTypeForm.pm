# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ImportedTransactionTypeForm;
use strict;
$Bivio::Biz::Model::ImportedTransactionTypeForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ImportedTransactionTypeForm::VERSION;

=head1 NAME

Bivio::Biz::Model::ImportedTransactionTypeForm - imported type selection form

=head1 SYNOPSIS

    use Bivio::Biz::Model::ImportedTransactionTypeForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::EditRowFormModel>

=cut

use Bivio::Biz::EditRowFormModel;
@Bivio::Biz::Model::ImportedTransactionTypeForm::ISA = ('Bivio::Biz::EditRowFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ImportedTransactionTypeForm>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::TypeError;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets the default selected row.

=cut

sub execute_empty {
    my($self) = @_;

    my($list) = $self->get_list_model;
    while ($list->next_row) {
	my($type) = $list->get('Entry.entry_type');
	$self->internal_put_field(selected_row => $list->get_cursor);
	$self->internal_put_field('imported_total_amount' => $list->get(
		'Entry.amount'));
	last;
    }
    $self->copy_list_fields;
    $self->validate if defined($self->get('selected_row'));
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Creates a member deposit transaction with entries for member and account.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($type) = $self->get('Entry.entry_type');

    # redirect to multiple payment/fee page if selected

    $req->server_redirect(Bivio::Agent::TaskId::CLUB_ACCOUNTING_PAYMENT())
	    if $type == $type->MEMBER_MULTIPLE_PAYMENT;

    $req->server_redirect(Bivio::Agent::TaskId::CLUB_ACCOUNTING_FEE())
	    if $type == $type-> MEMBER_MULTIPLE_PAYMENT_FEE;

    # otherwise go to the txn editor detail
    # preserves the query for date sort order
    $req->server_redirect(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_SYNC_IDENTIFY_DETAIL(),
	    $req->get('auth_realm'),
	    $req->get('query')
	   );

    # DOES NOT RETURN
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind()

Redirects to the main account sync identification page.

=cut

sub execute_unwind {
    my($self) = @_;

    # needs to be here to reset the list state
    $self->get_request->client_redirect(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_SYNC_IDENTIFY());

    # DOES NOT RETURN
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
            Entry.entry_type
        )],
	hidden => [qw(
            RealmTransaction.date_time
            RealmTransaction.realm_transaction_id
            AccountSync.sync_key
            AccountSync.import_date
            ),
	    {
		# Must be "unique" since other forms refer to this field
		name => 'imported_total_amount',
		type => 'Amount',
		constraint => 'NONE',
	    },
	],
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

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
