# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Tax1065;
use strict;
$Bivio::Biz::Model::Tax1065::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Tax1065::VERSION;

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
#use Bivio::Biz::Accounting::AllocationCache;
use Bivio::Biz::Model::Address;
use Bivio::Type::AllocationMethod;
use Bivio::Type::F1065IRSCenter;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;
use Bivio::Type::Location;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_load_for_report_date"></a>

=head2 static execute_load_for_report_date(Bivio::Agent::Request req)

Loads the tax 1065 model on the request, using the current report date
as a fiscal end date. The report_date must be on a fiscal boundary
or the load will die().

=cut

sub execute_load_for_report_date {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    $self->load_or_default($req->get('report_date'));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'tax_1065_t',
	columns => {
	    realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
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

=head2 load_or_default(string fiscal_end_date) : Bivio::Biz::Model::Tax1065

Loads or creates the 1065 model for the previous tax year.
Returns I<self>.

=cut

sub load_or_default {
    my($self, $fiscal_end_date) = @_;
    die('invalid fiscal end date '
	    .Bivio::Type::Date->to_literal($fiscal_end_date))
	    if $fiscal_end_date ne Bivio::Biz::Accounting::Tax
		    ->get_end_of_fiscal_year($fiscal_end_date);

    unless ($self->unsafe_load(fiscal_end_date => $fiscal_end_date)) {

	my($values);

	# use last year's values if present
	if ($self->unsafe_load(fiscal_end_date =>
		Bivio::Type::Date->get_previous_year($fiscal_end_date))) {
	    $values = $self->internal_get;
	}
	else {
	    # otherwise create with default values
	    $values = {
		realm_id => $self->get_request->get('auth_id'),
		partnership_type => Bivio::Type::F1065Partnership::GENERAL(),
		partnership_is_partner => 0,
		partner_is_partnership => 0,
		consolidated_audit => 1,
		publicly_traded => 0,
		tax_shelter => 0,
		foreign_account_country => undef,
		foreign_trust => 0,
		return_type => Bivio::Type::F1065Return::UNKNOWN(),
		irs_center => _get_default_irs_center($self),
		allocation_method =>
		Bivio::Type::AllocationMethod::TIME_BASED(),
		draft => 0,
	    };
	}
	$values->{fiscal_end_date} = $fiscal_end_date;
	$self->create($values);
    }
    return $self;
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

=head2 update(hash_ref new_values, boolean invalidate_allocations)

Overrides PropertyModel.update to invalidate the AllocationCache when
the allocation method is changed.

By default allocations will be invalidated if the allocation method
changes. To avoid this, specify invalidate_allocations as false.

=cut

sub update {
    my($self, $new_values, $invalidate_allocations) = @_;
    $invalidate_allocations = 1
	    unless defined($invalidate_allocations);

    my($allocation_method) = $new_values->{allocation_method};
    if (defined($allocation_method)
	    && $allocation_method != $self->get('allocation_method')
	    && $invalidate_allocations) {

	Bivio::Biz::Accounting::AllocationCache->new($self->get_request)
		    ->invalidate($self->get('fiscal_end_date'));
    }
    if (defined($new_values->{irs_center})
	    && $new_values->{irs_center}
	    == Bivio::Type::F1065IRSCenter::UNKNOWN()) {
	$new_values->{irs_center} = _get_default_irs_center($self);
    }
    $self->SUPER::update($new_values);
    return;
}

#=PRIVATE METHODS

# _get_default_irs_center() : Bivio::Type::F1065IRSCenter
#
# Returns the default irs center value based on the club's state.
#
sub _get_default_irs_center {
    my($self) = @_;

    # get the current realm's address
    my($address) = Bivio::Biz::Model::Address->new($self->get_request);
    $address->load(location => Bivio::Type::Location::HOME());
    return Bivio::Type::F1065IRSCenter->get_irs_center(
	    $address->get('state'), $address->get('zip'));
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
