# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel::InstrumentValuationList;
use strict;
$Bivio::Biz::ListModel::InstrumentValuationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel::InstrumentValuationList - 

=head1 SYNOPSIS

    use Bivio::Biz::ListModel::InstrumentValuationList;
    Bivio::Biz::ListModel::InstrumentValuationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::ListModel::InstrumentValuationList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::ListModel::InstrumentValuationList>

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Type::Amount;
use Bivio::Type::DateTime;
use Bivio::Biz::PropertyModel::RealmInstrument;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

All local fields.

=cut

sub internal_initialize {

    return {
	version => 1,
	other => [
	    {
	        name => 'name',
   	        type => 'Bivio::Type::String',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'first_buy_date',
   	        type => 'Bivio::Type::DateTime',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'shares',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'cost_per_share',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'total_cost',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'share_price',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'total_value',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'percent',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

Loads the valuation list with data. Uses the query realm and date parameters
to load values.

=cut

use Data::Dumper ();

sub internal_load {
    my($self, $rows, $query) = @_;

    $self->SUPER::internal_load($rows, $query);

    my($realm) = Bivio::Agent::Request->get_current()->get('auth_realm')
	    ->get('owner');

#TODO: get date from query if present
#TODO: is time() the correct default?
    my($date) = Bivio::Type::DateTime->to_sql_param(time());

    my($realm_value) = $realm->get_value($date);

    my($inst_info) = $realm->get_instruments_info();

    # iterate instruments and calculate values for the ones which
    # are currently owned

    my($inst);
    foreach $inst (@$inst_info) {
	my($id, $name) = @$inst;
	my($shares) = Bivio::Biz::PropertyModel::RealmInstrument
		->get_number_of_shares($id, $date);
	next if ($shares == 0);

	my($first_date) = Bivio::Biz::PropertyModel::RealmInstrument
		->get_first_buy_date($id);
#TODO: use Math::BigInt
	my($cost_per_share) = Bivio::Biz::PropertyModel::RealmInstrument
		->get_cost_per_share($id, $date);
	my($total_cost) = $shares * $cost_per_share;
	my($share_price) = Bivio::Biz::PropertyModel::RealmInstrument
		->get_share_price($id, $date);
#TODO: use Math::BigInt
	my($total_value) = $shares * $share_price;
	my($percent) = $total_value * 100 / $realm_value;

	push(@$rows, {name => $name, first_buy_date => $first_date,
	    shares => $shares, cost_per_share => $cost_per_share,
	    total_cost => $total_cost, share_price => $share_price,
	    total_value => $total_value, percent => $percent});
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
