# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::PropertyModel::Entry;
use strict;
$Bivio::Biz::PropertyModel::Entry::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Entry - interface to entry_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Entry;
    Bivio::Biz::PropertyModel::Entry->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::Entry::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Entry> is the create, read, update,
and delete interface to the C<entry_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::PrimaryId;
use Bivio::Type::TaxCategory;
use Bivio::Type::Text;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    return Bivio::SQL::Support->new('entry_t', {
        entry_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
        transaction_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::NOT_NULL()],
        class => ['Bivio::Type::EntryClass',
		Bivio::SQL::Constraint::NOT_NULL()],
        entry_type => ['Bivio::Type::EntryType',
		Bivio::SQL::Constraint::NOT_NULL()],
        tax_category => ['Bivio::Type::TaxCategory',
		Bivio::SQL::Constraint::NOT_NULL()],
        amount => ['Bivio::Type::Amount',
		Bivio::SQL::Constraint::NOT_NULL()],
        remark => ['Bivio::Type::Text',
		Bivio::SQL::Constraint::NONE()],
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
