# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Phone;
use strict;
$Bivio::Biz::Model::Phone::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Phone - interface to phone_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::Phone;
    Bivio::Biz::Model::Phone->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::LocationBase>

=cut

use Bivio::Biz::Model::LocationBase;
@Bivio::Biz::Model::Phone::ISA = qw(Bivio::Biz::Model::LocationBase);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Phone> is the create, read, update,
and delete interface to the C<phone_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Phone;
use Bivio::Type::Location;
use Bivio::Type::PrimaryId;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'phone_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            location => ['Bivio::Type::Location',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            phone => ['Bivio::Type::Phone',
    		Bivio::SQL::Constraint::NONE()],
        },
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
