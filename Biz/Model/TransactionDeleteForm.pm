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

=for html <a name="execute_empty"></a>

=head2 execute_empty() : boolean

Ensures that the Entry exists.

=cut

sub execute_empty {
    my($self) = @_;
    _check_exists($self);
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Deletes the selected entry, its transactions and all its entries.

=cut

sub execute_ok {
    my($self) = @_;

    my($entry) = _check_exists($self);

    # delete the related transaction and all its entries
    my($txn) = $entry->get_model('RealmTransaction');
    my($date) = $txn->get('date_time');

    $txn->cascade_delete;

    # need to update units after this date
    $self->get_request->get('auth_realm')->get('owner')->audit_units($date);

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	require_context => 1,
	auth_id => ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

# _check_exists() : Bivio::Biz::Model::Entry
#
# Ensures that selected entry exists, if not, redirects to the cancel
# task. This handles the case where the browser's back button is used
# to return to a previously deleted item.
#
sub _check_exists {
    my($self) = @_;
    my($req) = $self->get_request;

    # try to load the entry from the query
    # if it isn't present, then log a warning and cancel out

    # loads the entry
    my($entry) = Bivio::Biz::Model::Entry->new($req);
    unless ($req->get('query') && exists($req->get('query')->{t})
	    && $entry->unsafe_load(entry_id => $req->get('query')->{t})) {
	Bivio::IO::Alert->warn("attempt to delete missing entry");
	$self->execute_cancel;
	# DOES NOT RETURN
    }
    return $entry;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
