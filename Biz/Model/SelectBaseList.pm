# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SelectBaseList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('UI.Text');

sub internal_load {
    my($delegator, @args) = shift->delegated_args(@_);
    my(@res) = $delegator->SUPER::internal_load(@args);
    my($n) = $delegator->internal_select_field_name;
    unshift(
	@{$delegator->internal_get_rows},
	{
	    map(($_ => undef), @{$delegator->get_keys}),
	    $delegator->get_primary_id_name => $delegator->EMPTY_KEY_VALUE,
	    $n => $_T->get_value(
		$delegator->simple_package_name, $n, 'select_label'),
	},
    );
    return @res;
}

1;
