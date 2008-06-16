# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MonthList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');

sub internal_initialize {
    my($self) = @_;
    return {
	version => 1,
	@{$self->internal_initialize_local_fields(
	    other => [
                [qw(date Date)],
		[qw(month String)],
	    ],
	    undef, 'NONE',
	)},
    };
}

sub internal_load_rows {
    my($self) = @_;
    my($year) = $_D->get_part($_D->now, 'year');
    return [
        reverse(map(+{
            date => $_,
            month => $_D->english_month3($_D->get_part($_, 'month'))
                . ' ' . $_D->get_part($_, 'year'),
        }, map({
            my($year) = $_;
            map($_D->date_from_parts(1, $_, $year), (1 .. 12));
        } ($year - 1 .. $year + 1)))),
    ];
}

1;
