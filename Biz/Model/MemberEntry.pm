# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::MemberEntry;
use strict;
$Bivio::Biz::Model::MemberEntry::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MemberEntry - interface to member_entry_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberEntry;
    Bivio::Biz::Model::MemberEntry->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MemberEntry::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberEntry> is the create, read, update,
and delete interface to the C<member_entry_t> table.

=cut

#=IMPORTS
use Bivio::Biz::Model::Entry;
use Bivio::Type::EntryClass;
use Bivio::Type::TaxCategory;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_entry"></a>

=head2 static create_entry(Bivio::Biz::Model::RealmTransactions txn, hash_ref properties) : Bivio::Biz::Model::MemberEntry

=head2 create_entry(Bivio::Biz::Model::RealmTransactions txn, hash_ref properties) : Bivio::Biz::Model::MemberEntry

Creates the member entry, and transaction entry for the specified
transaction, using the values from the specified properties hash. Dies
on failure.

Defaults tax_category to NOT_TAXABLE, tax_basis to true, units to 0,
and valuation_date to undef.

=cut

sub create_entry {
    my($self, $txn, $properties) = @_;
    $self = $self->new($txn->get_request) unless ref($self);

    $properties->{class} = Bivio::Type::EntryClass::MEMBER();
    ($properties->{realm_id}, $properties->{realm_transaction_id})
	    = $txn->get('realm_id', 'realm_transaction_id');

    # defaults
    $properties->{tax_category} = Bivio::Type::TaxCategory::NOT_TAXABLE()
	    unless exists($properties->{tax_category});
    $properties->{tax_basis} = 1
	    unless exists($properties->{tax_basis});
    $properties->{units} = 0
	    unless exists($properties->{units});

    my($entry) = Bivio::Biz::Model::Entry->new($self->get_request);
    $entry->create($properties);

    $properties->{entry_id} = $entry->get('entry_id');
    $self->create($properties);
    return $self;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'member_entry_t',
	columns => {
            entry_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            user_id => ['PrimaryId', 'NOT_NULL'],
            units => ['Amount', 'NOT_NULL'],
	    valuation_date => ['Date', 'NONE'],
        },
	auth_id => 'realm_id',
#TODO: SECURITY: Not authenticated, but ok to load other models?
	other => [
	    [qw(entry_id Entry.entry_id)],
	    [qw(user_id User.user_id)],
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
