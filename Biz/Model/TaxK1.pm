# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TaxK1;
use strict;
$Bivio::Biz::Model::TaxK1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::TaxK1::VERSION;

=head1 NAME

Bivio::Biz::Model::TaxK1 - IRS K-1 tax parameters

=head1 SYNOPSIS

    use Bivio::Biz::Model::TaxK1;
    Bivio::Biz::Model::TaxK1->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::TaxK1::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::TaxK1> IRS K-1 tax parameters

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
	table_name => 'tax_k1_t',
	columns => {
	    realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	    user_id => ['PrimaryId', 'PRIMARY_KEY'],
	    fiscal_end_date => ['Date', 'PRIMARY_KEY'],
	    entity_type => ['F1065Entity', 'NOT_NULL'],
	    partner_type => ['F1065Partner', 'NOT_NULL'],
	    foreign_partner => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="load_or_default"></a>

=head2 load_or_default(string user_id, string fiscal_end_date)

Loads or creates a new k1 for the specified user and tax year.
Return I<self>.

=cut

sub load_or_default {
    my($self, $user_id, $fiscal_end_date) = @_;
    die('invalid fiscal end date '
	    .Bivio::Type::Date->to_literal($fiscal_end_date))
	    if $fiscal_end_date ne Bivio::Biz::Accounting::Tax
		    ->get_end_of_fiscal_year($fiscal_end_date);

    unless ($self->unsafe_load(fiscal_end_date => $fiscal_end_date,
	    user_id => $user_id)) {

	my($values);

	# use last year's values if present
	if ($self->unsafe_load(fiscal_end_date =>
		Bivio::Type::Date->get_previous_year($fiscal_end_date),
		user_id => $user_id)) {
	    $values = $self->internal_get;
	}
	else {
	    # otherwise create with default values
	    $values = {
		realm_id => $self->get_request->get('auth_id'),
		user_id => $user_id,
		entity_type => Bivio::Type::F1065Entity->INDIVIDUAL,
		partner_type => Bivio::Type::F1065Partner->GENERAL,
		foreign_partner => 0,
	    };
	}

	$values->{fiscal_end_date} = $fiscal_end_date;
	$self->create($values);
    }
    return $self;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
