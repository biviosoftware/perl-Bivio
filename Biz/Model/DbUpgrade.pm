# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::DbUpgrade;
use strict;
$Bivio::Biz::Model::DbUpgrade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::DbUpgrade - database upgrade indicator

=head1 SYNOPSIS

    use Bivio::Biz::Model::DbUpgrade;
    Bivio::Biz::Model::DbUpgrade->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::DbUpgrade::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::DbUpgrade> database upgrade indicator

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Name;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'db_upgrade_t',
	columns => {
            version => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    run_date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
