# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Tax1065;
use strict;
$Bivio::Biz::Model::Tax1065::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Tax1065 - IRS 1065 tax parameters

=head1 SYNOPSIS

    use Bivio::Biz::Model::Tax1065;
    Bivio::Biz::Model::Tax1065->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::Tax1065::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::Tax1065> IRS 1065 tax parameters

=cut

#=IMPORTS
use Bivio::Biz::Model::Address;
use Bivio::Type::AllocationMethod;
use Bivio::Type::F1065IRSCenter;
use Bivio::Type::Location;

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
	table_name => 'tax_1065_t',
	columns => {
	    realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	    fiscal_end_date => ['Date', 'PRIMARY_KEY'],
	    partnership_type => ['F1065Partnership', 'NOT_NULL'],
	    partner_is_partnership => ['Boolean', 'NOT_NULL'],
	    partnership_is_partner => ['Boolean', 'NOT_NULL'],
	    consolidated_audit => ['Boolean', 'NOT_NULL'],
	    publicly_traded => ['Boolean', 'NOT_NULL'],
	    tax_shelter => ['Boolean', 'NOT_NULL'],
	    foreign_account_country => ['Country', 'NONE'],
	    foreign_trust => ['Boolean', 'NOT_NULL'],
	    return_type => ['F1065Return', 'NOT_NULL'],
	    irs_center => ['F1065IRSCenter', 'NOT_NULL'],
	    allocation_method => ['AllocationMethod', 'NOT_NULL'],
	    draft => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="load_or_default"></a>

=head2 load_or_default(string fiscal_end_date)

Loads or creates the 1065 model for the previous tax year.

=cut

sub load_or_default {
    my($self, $fiscal_end_date) = @_;
    unless ($self->unsafe_load(fiscal_end_date => $fiscal_end_date)) {
	$self->create({
	    realm_id => $self->get_request->get('auth_id'),
	    fiscal_end_date => $fiscal_end_date,
	    partnership_type => Bivio::Type::F1065Partnership::GENERAL(),
	    partnership_is_partner => 0,
	    partner_is_partnership => 0,
	    consolidated_audit => 1,
	    publicly_traded => 0,
	    tax_shelter => 0,
	    foreign_account_country => undef,
	    foreign_trust => 0,
	    return_type => Bivio::Type::F1065Return::UNKNOWN(),
	    irs_center => Bivio::Type::F1065IRSCenter->UNKNOWN,
	    allocation_method => Bivio::Type::AllocationMethod::TIME_BASED(),
	    draft => 1,
	});
    }

    # determine irs center based on club address
    if ($self->get('irs_center') == Bivio::Type::F1065IRSCenter::UNKNOWN()) {
	# get the current realm's address
	my($address) = Bivio::Biz::Model::Address->new($self->get_request);
	$address->load(location => Bivio::Type::Location::HOME());
	$self->update({
	    irs_center => Bivio::Type::F1065IRSCenter->get_irs_center(
		    $address->get('state'), $address->get('zip'))
	});
    }

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
