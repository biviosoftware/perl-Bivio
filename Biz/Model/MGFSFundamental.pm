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
use Bivio::Data::MGFS::AuditorReport;
use Bivio::Data::MGFS::DataType;
use Bivio::Data::MGFS::Date;
use Bivio::Data::MGFS::DowJonesMember;
use Bivio::Data::MGFS::Industry;
use Bivio::Data::MGFS::Market;
use Bivio::Data::MGFS::Number10;
use Bivio::Data::MGFS::SPIndustry;
use Bivio::Data::MGFS::SPMember;
use Bivio::Data::MGFS::State;
use Bivio::Type::Amount;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
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
	table_name => 'mgfs_fundamental_t',
	columns => {
	    instrument_id => ['Bivio::Type::PrimaryId',
		    Bivio::SQL::Constraint::NONE()],
	    data_type => ['Bivio::Data::MGFS::DataType',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    mg_sequence => ['Bivio::Type::String',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
	    ticker_symbol => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    market => ['Bivio::Data::MGFS::Market',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    industry => ['Bivio::Data::MGFS::Industry',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    primary_sic => ['Bivio::Type::Integer',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    dow_jones_member => ['Bivio::Data::MGFS::DowJonesMember',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    sp_member => ['Bivio::Data::MGFS::SPMember',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    sp_industry => ['Bivio::Data::MGFS::SPIndustry',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    name => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    street1 => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    street2 => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    city => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    state => ['Bivio::Data::MGFS::State',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    zip => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    phone => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    fax => ['Bivio::Type::Name',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    ceo => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    description => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    short_interest_latest_date => ['Bivio::Data::MGFS::Date',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    net_insider_last_date => ['Bivio::Data::MGFS::Date',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    inst_holdings_last_date => ['Bivio::Data::MGFS::Date',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    inst_holding_percent => ['Bivio::Type::Amount',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    employees => ['Bivio::Data::MGFS::Number10',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    auditor_name => ['Bivio::Type::Line',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    auditor_last_report => ['Bivio::Data::MGFS::AuditorReport',
		    Bivio::SQL::Constraint::NOT_NULL()],
	    business_description => ['Bivio::Type::Text',
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
