# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSFundamental;
use strict;
$Bivio::Biz::Model::MGFSFundamental::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSFundamental - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSFundamental;
    Bivio::Biz::Model::MGFSFundamental->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSFundamental::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSFundamental>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Id;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    indb01 => [0, 0],
	    chgdb01 => [0, 1],
	},
	format => [
	    {
	        data_type => ['CHAR', 4, 1],
		# skip leading '+'
		mg_id => ['ID', 44, 8],
		inst_holding_percent => ['PERCENT', 1027, 6],
		employees => ['ACTUAL', 1033, 10],
	    },
	],
    };
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_fundamental_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    data_type => ['Bivio::Data::MGFS::DataType',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    inst_holding_percent => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    employees => ['Bivio::Data::MGFS::Amount',
		    Bivio::SQL::Constraint::NONE()],
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
