# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Iterator test
#
use strict;
use Bivio::Test;
use Bivio::PetShop::Model::ProductList;
use Bivio::Test::Request;
my($it);
Bivio::Test->unit([
    (map {
	({
	    # Two groups: without $it and with $it (DEPRECATED)
	    $_ ? (compute_params => sub {
		my($case, $params) = @_;
		return $case->get('method') eq 'iterate_start'
		    ? $params : [$it, @$params];
	    }) : (),
	    object => Bivio::PetShop::Model::ProductList->new(
		Bivio::Test::Request->get_instance),
	} => [
	    iterate_start => [
		[{parent_id => 'FISH'}] => sub {
		    my($case, $return) = @_;
		    return ref($it = $return->[0]) ? 1 : 0;
		},
	    ],
	    iterate_next_and_load => sub {
		my($case, $return) = @_;
		$case->actual_return(
		    [$case->get('object')->get('Product.name')]);
		return ['Angelfish'];
	    },
	    iterate_next_and_load => 1,
	    iterate_next => [
		[{}] => sub {
		    my($case, $return) = @_;
		    $case->actual_return([
			$case->get('params')->[
			    ref($case->get('params')->[0]) eq 'HASH' ? 0 : 1],
		    ]);
		    return [{
			'Product.product_id' => 'FI-FW-01',
                        'Product.category_id' => 'FISH',
			'Product.name' => 'Koi',
		    }];
		},
	    ],
	    iterate_next_and_load => 1,
	    iterate_next_and_load => 0,
	    iterate_end => undef,
	]);
    } 0..1),

    # Deviance
    Bivio::PetShop::Model::ProductList->new(
	Bivio::Test::Request->get_instance) => [
	iterate_end => [
	    [] => Bivio::DieCode->DIE,
	],
	iterate_start => [
	    [{parent_id => 'REPTILES'}] => undef,
	],
        iterate_next_and_load => [
	    [{}] => Bivio::DieCode->DIE,
	],
        iterate_next => [
	    [[], {}] => Bivio::DieCode->DIE,
	],
    ],
]);
