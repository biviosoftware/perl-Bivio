# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::UI::Widget::Join;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->setup_facade;
Bivio::Biz::Model->new($_req, 'ProductList')->load_all({
    parent_id => 'DOGS',
});
Bivio::Test->new({
    class_name => 'Bivio::UI::Text::Widget::CSV',
    check_return => sub {
	my($case, undef, $expect) = @_;
	$case->actual_return([
	    $case->get('params')->[1],
	]) if $case->get('method') eq 'render';
	return $expect;
    },
})->unit([
    ['ProductList', ['Product.name', 'Product.product_id']] => [
	initialize => undef,
	render => [
	    [$_req, \(my $x = '')] => qr/Product Name,Product ID\nCorgi,K9-BD-01\nDalmation.*Poodle/s,
	],
    ],
    ['ProductList', [
	['Product.name', {column_heading => 'Name'}],
	['Product.product_id', {column_heading => 'Id'}],
    ]] => [
	initialize => undef,
	render => [
	    [$_req, \(my $y = '')] => qr/Name,Id\nCorgi,K9-BD-01\nDalmation.*Poodle/s,
	],
    ],
    ['ProductList', [
	['Product.name', {
	    column_heading => Bivio::UI::Widget::Join->new(['Name']),
	}],
	['Product.product_id', {
	    column_widget => Bivio::UI::Widget::Join->new(['ID: ', ['Product.product_id']]),
	}],
    ]] => [
	initialize => undef,
	render => [
	    [$_req, \(my $y2 = '')] => qr/Name,Product ID\nCorgi,ID: K9-BD-01\nDalmation.*Poodle/s,
	],
    ],
    ['ProductList', [
	# Specify compatible type instead of Line
	['Product.name', {type => Bivio::Type->get_instance('Name')}],
	'Product.product_id',
    ]] => [
	initialize => undef,
	render => [
	    [$_req, \(my $z = '')] => qr/Product Name,Product ID\nCorgi,K9-BD-01\nDalmation.*Poodle/s,
	],
    ],
    ['ProductList', [
	['Product.name', {
	    column_heading => 'Product',
	    type => Bivio::Type->get_instance('Name'),
	}],
	'Product.product_id',
    ]] => [
	initialize => undef,
	render => [
	    [$_req, \(my $z2 = '')] => qr/Product,Product ID\nCorgi,K9-BD-01\nDalmation.*Poodle/s,
	],
    ],
    ['ProductList', [
	['Product.name', {
            column_control => [sub {return 0}],
	}],
	['Product.product_id', {
            column_control => [sub {return 1}],
        }],
    ]] => [
	initialize => undef,
	render => [
	    [$_req, \(my $z3 = '')] => qr/Product ID\nK9-BD-01\n/s,
	],
    ],
    ['ProductList', [
	# Test invalid type
	['Product.name', {type => Bivio::Type->get_instance('Date')}],
    ]] => [
	initialize => undef,
	render => [
            [$_req, \(my $z4 = '')] => Bivio::DieCode->DIE,
        ],
    ],
]);
