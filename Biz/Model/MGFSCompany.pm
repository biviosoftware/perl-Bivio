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

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSCompany::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSCompany>

=cut

#=IMPORTS
use Bivio::Data::MGFS::AuditorReport;
use Bivio::Data::MGFS::Boolean;
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Date;
use Bivio::Data::MGFS::Domicile;
use Bivio::Data::MGFS::DowJonesMember;
use Bivio::Data::MGFS::Fortune500Industrial;
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::Industry;
use Bivio::Data::MGFS::Market;
use Bivio::Data::MGFS::Number10;
use Bivio::Data::MGFS::SPIndustry;
use Bivio::Data::MGFS::SPMember;
use Bivio::Type::Amount;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
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
	    instrument_id => ['Bivio::Type::PrimaryId',
		    Bivio::SQL::Constraint::NONE()],
	    ticker_symbol => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    cusip => ['Bivio::Type::String',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    market => ['Bivio::Data::MGFS::Market',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    industry => ['Bivio::Type::String',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    primary_sic => ['Bivio::Type::Integer',
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
