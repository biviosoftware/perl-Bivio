# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::PropertyModel::RealmUser;
use strict;
$Bivio::Biz::PropertyModel::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::RealmUser - interface to realm_user_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::RealmUser;
    Bivio::Biz::PropertyModel::RealmUser->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::RealmUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::RealmUser> is the create, read, update,
and delete interface to the C<realm_user_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::PrimaryId;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    return Bivio::SQL::Support->new('realm_user_t', {
        realm_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
        user_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
        role => ['Bivio::Auth::Role',
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
