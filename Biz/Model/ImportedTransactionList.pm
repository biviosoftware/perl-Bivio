# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ImportedTransactionList;
use strict;
$Bivio::Biz::Model::ImportedTransactionList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ImportedTransactionList::VERSION;

=head1 NAME

Bivio::Biz::Model::ImportedTransactionList - imported account sync txns

=head1 SYNOPSIS

    use Bivio::Biz::Model::ImportedTransactionList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ImportedTransactionList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ImportedTransactionList> imported account sync txns

=cut

#=IMPORTS
use Bivio::Biz::Action::EditTransaction;
use Bivio::Biz::Model::RealmTransaction;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="can_edit"></a>

=head2 can_edit() : boolean

Returns true if the current row can be edited.

=cut

sub can_edit {
    my($self) = @_;
    return Bivio::Biz::Action::EditTransaction->can_edit(
	    $self->get('Entry.entry_type'));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	auth_id => [qw(RealmTransaction.realm_id)],
	order_by => [qw(
            RealmTransaction.date_time
            AccountSync.sync_key
            RealmTransaction.realm_transaction_id
        )],
	primary_key => [
	    [qw(Entry.entry_id)],
	],
	other => [
	    qw(
            RealmTransaction.source_class
            RealmTransaction.remark
            Entry.amount
            Entry.class
            Entry.entry_type
            AccountSync.sync_key
            RealmAccount.realm_account_id
	    ),
	    {
		name => 'RealmTransaction.realm_transaction_id',
		sort_order => 0,
	    },
	    [qw{RealmTransaction.realm_transaction_id
                Entry.realm_transaction_id}],
	    [qw{Entry.entry_id RealmAccountEntry.entry_id}],
	    [qw{RealmAccountEntry.realm_account_id
                RealmAccount.realm_account_id}],
	    [qw{RealmTransaction.realm_transaction_id
                AccountSync.realm_transaction_id}],
	],
    };
}

=for html <a name="internal_post_load_row"></a>

=head2 abstract internal_post_load_row(hash_ref row)

Generates a remark for the row.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;

    return if $row->{'RealmTransaction.source_class'}
	    == Bivio::Type::EntryClass::CASH();

    # generate a remark for each row (slow)
    $row->{'RealmTransaction.remark'} = Bivio::Biz::Model::RealmTransaction
	    ->new($self->get_request)->load(realm_transaction_id =>
		    $row->{'RealmTransaction.realm_transaction_id'})
		    ->generate_entry_remark();
    return;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
