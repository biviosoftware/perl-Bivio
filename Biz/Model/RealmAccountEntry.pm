# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmAccountEntry;
use strict;
$Bivio::Biz::Model::RealmAccountEntry::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmAccountEntry - interface to realm_account_entry_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmAccountEntry;
    Bivio::Biz::Model::RealmAccountEntry->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmAccountEntry::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmAccountEntry> is the create, read, update,
and delete interface to the C<realm_account_entry_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::PrimaryId;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_entry"></a>

=head2 create_entry(Bivio::Biz::Model::RealmTransactions trans, hash_ref properties)

Creates the account entry, and transaction entry for the specified
transaction, using the values from the specified properties hash. Dies
on failure.

=cut

sub create_entry {
    my($self, $trans, $properties) = @_;

    $properties->{class} = Bivio::Type::EntryClass::CASH();
    $properties->{realm_transaction_id} = $trans->get('realm_transaction_id');

    my($entry) = Bivio::Biz::Model::Entry->new($self->get_request);
    $entry->create($properties);

    $properties->{entry_id} = $entry->get('entry_id');
    $self->create($properties);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_account_entry_t',
	columns => {
            entry_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            realm_account_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
	other => [
	    [qw(realm_account_id RealmAccount.realm_account_id)],
	    [qw(entry_id RealmInstrumentEntry.entry_id)],
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
