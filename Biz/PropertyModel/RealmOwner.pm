# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::PropertyModel::RealmOwner;
use strict;
$Bivio::Biz::PropertyModel::RealmOwner::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::RealmOwner - interface to realm_owner_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::RealmOwner;
    Bivio::Biz::PropertyModel::RealmOwner->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::RealmOwner::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::RealmOwner> is the create, read, update,
and delete interface to the C<realm_owner_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    return Bivio::SQL::Support->new('realm_owner_t', {
        name => ['Bivio::Type::Name',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
        password => ['Bivio::Type::Name',
		Bivio::SQL::Constraint::NOT_NULL()],
        realm_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::NOT_NULL_UNIQUE()],
        realm_type => ['Bivio::Auth::RealmType',
		Bivio::SQL::Constraint::NOT_NULL()],
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
