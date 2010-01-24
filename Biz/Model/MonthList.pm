# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MonthList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Type.Date');
my($_T) = b_use('FacadeComponent.Text');


sub internal_initialize {
    my($self) = @_;
    return {
	version => 1,
	$self->field_decl(
	    primary_key => [
                [qw(date Date)],
	    ],
	    order_by => [
		[qw(display_name String)],
	    ],
	),
	other_query_keys => ['b_month'],
    };
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($now) = $_D->set_beginning_of_month($_D->now);
    my($date) = $now;
    if (my $bm = $query->unsafe_get('b_month')) {
	$bm = ($_D->from_literal($bm))[0];
	$date = $bm
	    if $bm;
    }
    my($year) = $_D->get_part($date, 'year');
    my($t) = $_T->get_from_source($self->req);
    return [
	{
	    # Need to make distinct value in list
	    date => $_D->add_days($now, 1),
	    display_name => $t->get_value(
		$self->simple_package_name, 'this_month'),
	},
        map(+{
            date => $_,
            display_name => $t->get_value(
		$self->simple_package_name,
		$_D->english_month3($_D->get_part($_, 'month')),
	    ) . ' '
	    . $_D->get_part($_, 'year'),
        }, map({
            my($year) = $_;
            map($_D->date_from_parts(1, $_, $year), 1 .. 12);
        } ($year - 1 .. $year + 1))),
    ];
}

1;
