# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TransactionDeleteForm;
use strict;
$Bivio::Biz::Model::TransactionDeleteForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::TransactionDeleteForm - deletes a transaction and entries

=head1 SYNOPSIS

    use Bivio::Biz::Model::TransactionDeleteForm;
    Bivio::Biz::Model::TransactionDeleteForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::TransactionDeleteForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::TransactionDeleteForm> deletes a transaction and entries

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_ENTRY_KEY) = 'ek';

=head1 METHODS

=cut

=for html <a name="execute_cancel"></a>

=head2 execute_cancel()


=cut

sub execute_cancel {
    my($self) = @_;

    # hack to remove special query key
    delete($self->get_request->get('query')->{$_ENTRY_KEY});
    return;
}

=for html <a name="execute_empty"></a>

=head2 execute_empty()


=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;

    # load the entry from the special key, set in the appropriate tran list
    my($entry) = Bivio::Biz::Model::Entry->new($req);
    $entry->load(entry_id => $req->get('query')->{$_ENTRY_KEY});

    # sets the hidden transacion id field (not used!)
    $self->internal_get()->{'RealmTransaction.realm_transaction_id'}
	    = $entry->get('realm_transaction_id');

    # hack to remove special query key
    delete($self->get_request->get('query')->{$_ENTRY_KEY});
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Deletes the selected entry, its transactions and all its entries.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;

    # loads the entry
    my($entry) = Bivio::Biz::Model::Entry->new($req);
    $entry->load(entry_id => $req->get('query')->{$_ENTRY_KEY});

    # delete the related transaction and all its entries
    $entry->get_model('RealmTransaction')->cascade_delete;

    # hack to remove special query key
    delete($self->get_request->get('query')->{$_ENTRY_KEY});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	hidden => [
	    'RealmTransaction.realm_transaction_id',
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
	primary_key => [
	    'RealmTransaction.realm_transaction_id',
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
