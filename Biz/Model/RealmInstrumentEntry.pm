# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmInstrumentEntry;
use strict;
$Bivio::Biz::Model::RealmInstrumentEntry::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmInstrumentEntry - interface to realm_instrument_entry_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInstrumentEntry;
    Bivio::Biz::Model::RealmInstrumentEntry->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmInstrumentEntry::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInstrumentEntry> is the create, read, update,
and delete interface to the C<realm_instrument_entry_t> table.

=cut

#=IMPORTS
use Bivio::Biz::Model::Entry;
use Bivio::Type::EntryClass;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_entry"></a>

=head2 create_entry(Bivio::Biz::Model::RealmTransactions trans, hash_ref properties)

Creates the instrument entry, and transaction entry for the specified
transaction, using the values from the specified properties hash. Dies
on failure.

Defaults tax_basis, count, and external_identifer to 0 unless specified.

=cut

sub create_entry {
    my($self, $trans, $properties) = @_;

    $properties->{class} = Bivio::Type::EntryClass::INSTRUMENT();
    ($properties->{realm_id}, $properties->{realm_transaction_id})
	    = $trans->get('realm_id', 'realm_transaction_id');

    # defaults
    $properties->{tax_basis} = 0 unless exists($properties->{tax_basis});
    $properties->{count} = 0 unless exists($properties->{count});
    $properties->{external_identifier} = 0
	    unless exists($properties->{external_identifier});

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
	table_name => 'realm_instrument_entry_t',
	columns => {
            entry_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            realm_instrument_id => ['PrimaryId', 'NOT_NULL'],
            count => ['Amount', 'NOT_NULL'],
            external_identifier => ['Name', 'NOT_NULL'],
	    acquisition_date => ['Date', 'NONE'],
        },
	other => [
	    [qw(entry_id Entry.entry_id)],
	    [qw(realm_instrument_id RealmInstrument.realm_instrument_id)],
	],
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
