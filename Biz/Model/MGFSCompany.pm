# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSCompany;
use strict;
$Bivio::Biz::Model::MGFSCompany::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSCompany - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSCompany;
    Bivio::Biz::Model::MGFSCompany->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSCompany::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSCompany>

=cut

#=IMPORTS
use Bivio::Data::MGFS::AuditorReport;
use Bivio::Data::MGFS::Boolean;
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Domicile;
use Bivio::Data::MGFS::DowJonesMember;
use Bivio::Data::MGFS::Fortune500Industrial;
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::IndustryId;
use Bivio::Data::MGFS::Market;
use Bivio::Data::MGFS::SICCode;
use Bivio::Data::MGFS::SPIndustry;
use Bivio::Data::MGFS::SPMember;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::State;
use Bivio::Data::MGFS::Ratio;
use Bivio::Data::MGFS::RussellMember;
use Bivio::Data::MGFS::StockOptions;
use Bivio::Data::MGFS::SPMidCap;
use Bivio::Type::Text;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file)

Creates/updates an MGFS model from the MGFS record format.
Skips non stock files.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;

    # only record types of D
    # skips industry/index/composite records
    if (substr($record, 4, 1) eq 'D') {
	$self->SUPER::from_mgfs($record, $file);
    }

#TODO: create split records

    return;
}

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
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		cusip => ['CHAR', 54, 9],
		market => ['CHAR', 52, 2],
		industry => ['CHAR', 63, 3],
		primary_sic => ['CHAR', 66, 5],
		dow_jones_member => ['CHAR', 121, 2],
		sp_member => ['CHAR', 123, 2],
		sp_industry => ['CHAR', 125, 4],
		street1 => ['CHAR', 159, 27],
		street2 => ['CHAR', 187, 27],
		city => ['CHAR', 215, 20],
		state => ['CHAR', 235, 2],
		zip => ['CHAR', 237, 10],
		phone => ['CHAR', 247, 14],
		fax => ['CHAR', 261, 14],
		ceo => ['CHAR', 275, 50],
		description => ['CHAR', 325, 50],
		sp_midcap => ['CHAR', 375, 2],
		stock_options => ['CHAR', 377, 2],
		russell_member => ['CHAR', 381, 2],
		bankruptcy => ['CHAR', 395, 1],
		drp => ['CHAR', 396, 1],
		domicile => ['CHAR', 397, 2],
		adr_ratio => ['CHAR', 399, 8],
		forbes500_member => ['CHAR', 407, 1],
		fortune500_industrial => ['CHAR', 408, 1],
		fortune500_services => ['CHAR', 409, 2],
		auditor_name => ['CHAR', 1043, 50],
		auditor_last_report => ['CHAR', 1093, 2],
		business_description => ['CHAR', 1095, 256],
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
	table_name => 'mgfs_company_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    cusip => ['Bivio::Type::String',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    market => ['Bivio::Data::MGFS::Market',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    industry => ['Bivio::Data::MGFS::IndustryId',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    primary_sic => ['Bivio::Data::MGFS::SICCode',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    dow_jones_member => ['Bivio::Data::MGFS::DowJonesMember',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    sp_member => ['Bivio::Data::MGFS::SPMember',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    sp_industry => ['Bivio::Data::MGFS::SPIndustry',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    street1 => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    street2 => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    city => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    state => ['Bivio::Type::State',
		    Bivio::SQL::Constraint::NONE()],
	    zip => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    phone => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    fax => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NONE()],
	    ceo => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NONE()],
	    description => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NONE()],
	    auditor_name => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NONE()],
	    auditor_last_report => ['Bivio::Data::MGFS::AuditorReport',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    business_description => ['Bivio::Type::Text',
		    Bivio::SQL::Constraint::NONE()],
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
		    Bivio::SQL::Constraint::NONE()],
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
