# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::DbUpgrade;
use strict;
$Bivio::Biz::Model::DbUpgrade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::DbUpgrade::VERSION;

=head1 NAME

Bivio::Biz::Model::DbUpgrade - maintains current database DDL version

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::DbUpgrade;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::DbUpgrade::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::DbUpgrade> database upgrade indicator.  Applications
should create a program, e.g. db-upgrade, which contains the current upgrade.
When the upgrade is complete (before the commit), this table should be updated
with the CVS revision of the upgrade.  Since there is a unique key on
db_upgrade_t.version, an upgrade can't run twice.

=cut

#=IMPORTS

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
	    # Which version, can be anything, but must be unique
            version => ['Name', 'PRIMARY_KEY'],
	    # When did the upgrade run?
	    run_date_time => ['DateTime', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
