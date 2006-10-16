# Copyright (c) 2002 bivio Software, Inc.  All rights reserved.
# $Id$
#
# Iterator test
#
use strict;
use Bivio::Test;
use Bivio::PetShop::Model::Product;
use Bivio::Test::Request;
my($it);
Bivio::Test->unit([
    (map {
	({
	    # Two groups: without $it and with $it (DEPRECATED)x
	    $_ ? (compute_params => sub {
		my($case, $params) = @_;
		return $case->get('method') eq 'iterate_start'
		    ? $params : [$it, @$params];
	    }) : (),
	    object => Bivio::PetShop::Model::Product->new(
		Bivio::Test::Request->get_instance),
	} => [
	    iterate_start => [
		['product_id asc', {category_id => 'FISH'}] => sub {
		    my($case, $return) = @_;
		    return ref($it = $return->[0]) ? 1 : 0;
		},
	    ],
	    iterate_next_and_load => sub {
		my($case, $return) = @_;
		$case->actual_return(
		    [$case->get('object')->get('product_id')]);
		return ['FI-FW-01'];
	    },
	    iterate_next_and_load_new => sub {
		my($case, $return) = @_;
		$case->actual_return([$return->[0]->get('product_id')]);
		return ['FI-FW-02'];
	    },
	    iterate_next => [
		[{}] => sub {
		    my($case, $return) = @_;
		    $case->actual_return([
			$case->get('params')->[
			    ref($case->get('params')->[0]) eq 'HASH' ? 0 : 1],
		    ]);
		    return [{
			product_id => 'FI-SW-01',
			category_id => 'FISH',
			name => 'Angelfish',
			image_name => 'angelfish',
			description => 'Salt Water fish from Australia',
		    }];
		},
	    ],
	    iterate_next_and_load => 1,
	    iterate_next_and_load => 0,
	    iterate_end => undef,

	]);
    } 0..1),

    # Deviance
    Bivio::PetShop::Model::Product->new(
	Bivio::Test::Request->get_instance) => [
	iterate_end => [
	    [] => Bivio::DieCode->DIE,
	],
	iterate_start => [
	    ['product_id desc', {category_id => 'REPTILES'}] => undef,
	],
        iterate_next_and_load => [
	    [{}] => Bivio::DieCode->DIE,
	],
        iterate_next => [
	    [[], {}] => Bivio::DieCode->DIE,
	],
    ],
]);
