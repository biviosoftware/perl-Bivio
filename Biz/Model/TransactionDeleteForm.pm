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

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Deletes the selected entry, its transactions and all its entries.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;

    # loads the entry
    my($entry) = $req->get('Bivio::Biz::Model::Entry');

    # delete the related transaction and all its entries
    $entry->get_model('RealmTransaction')->cascade_delete;

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
	auth_id => ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
