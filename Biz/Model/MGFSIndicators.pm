# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSIndicators;
use strict;
$Bivio::Biz::Model::MGFSIndicators::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSIndicators - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSIndicators;
    Bivio::Biz::Model::MGFSIndicators->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSIndicators::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSIndicators>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Boolean;
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Domicile;
use Bivio::Data::MGFS::Fortune500Industrial;
use Bivio::Data::MGFS::Ratio;
use Bivio::Data::MGFS::RussellMember;
use Bivio::Data::MGFS::StockOptions;
use Bivio::Data::MGFS::SPMidCap;

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
	table_name => 'mgfs_indicators_t',
	columns => {
	    instrument_id => ['Bivio::Type::PrimaryId',
		    Bivio::SQL::Constraint::NONE()],
	    data_type => ['Bivio::Data::MGFS::DataType',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    mg_sequence => ['Bivio::Type::String',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    sp_midcap => ['Bivio::Data::MGFS::SPMidCap',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    stock_options => ['Bivio::Data::MGFS::StockOptions',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    russell_member => ['Bivio::Data::MGFS::RussellMember',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    bankruptcy => ['Bivio::Data::MGFS::Boolean',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    drp => ['Bivio::Data::MGFS::Boolean',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    domicile => ['Bivio::Data::MGFS::Domicile',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    adr_ratio => ['Bivio::Data::MGFS::Ratio',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    forbes500_member => ['Bivio::Data::MGFS::Boolean',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    fortune500_industrial => [
		    'Bivio::Data::MGFS::Fortune500Industrial',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    fortune500_services => ['Bivio::Data::MGFS::Boolean',
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
