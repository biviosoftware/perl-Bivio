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

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSFundamental::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSFundamental>

=cut

#=IMPORTS
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Id;
use Bivio::Type::Amount;
use Bivio::Type::Name;
use Bivio::Type::String;

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
	table_name => 'mgfs_fundamental_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    data_type => ['Bivio::Data::MGFS::DataType',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    name => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    inst_holding_percent => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NONE()],
	    employees => ['Bivio::Type::Amount',
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
