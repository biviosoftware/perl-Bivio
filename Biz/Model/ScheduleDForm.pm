# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ScheduleDForm;
use strict;
$Bivio::Biz::Model::ScheduleDForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ScheduleDForm - IRS 1065 Schedule D fields

=head1 SYNOPSIS

    use Bivio::Biz::Model::ScheduleDForm;
    Bivio::Biz::Model::ScheduleDForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel> IRS 1065 Schedule D fields

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ScheduleDForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ScheduleDForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads all fields.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;

    my($list) = $req->get('Bivio::Biz::Model::InstrumentSaleList');
    my($stcg) = $req->get($list->get_request_key(
	    Bivio::Type::TaxCategory::SHORT_TERM_CAPITAL_GAIN()));
    my($ltcg) = $req->get($list->get_request_key(
	    Bivio::Type::TaxCategory::LONG_TERM_CAPITAL_GAIN()));

    # need to separate the cash distributions from sales
    # cash distributions are included with net LTCG
    my($stcg_sum, $stcg_dist) = _get_sum_and_dist($stcg);
    my($ltcg_sum, $ltcg_dist) = _get_sum_and_dist($ltcg);
    my($dist) = Bivio::Type::Amount->add($stcg_dist, $ltcg_dist);

    $properties->{total_stcg} = $stcg_sum;
    $properties->{net_stcg} = $stcg_sum;
    $properties->{gain_distributions} = $dist;
    $properties->{total_ltcg} = $ltcg_sum;
    $properties->{net_ltcg} = Bivio::Type::Amount->add($ltcg_sum, $dist);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	hidden => [
	    {
		name => 'net_stcg',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'gain_distributions',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'net_ltcg',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'total_stcg',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'total_ltcg',
		type => 'Amount',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

#=PRIVATE METHODS

# _get_sum_and_dist(Bivio::Biz::Model::InstrumentSaleList list) : (string, string)
#
# Returns the sum of the list, with any distribution separate.
#
sub _get_sum_and_dist {
    my($list) = @_;
    my($summary) = $list->get_summary;
    $summary->next_row;
    my($gain) = $summary->get('gain');

    my($dist) = 0;
    $list->reset_cursor;
    while ($list->next_row) {
	if ($list->is_distribution) {
	    $dist = $list->get('gain');
	    $gain = Bivio::Type::Amount->sub($gain, $dist);
	}
    }
    return ($gain, $dist);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
