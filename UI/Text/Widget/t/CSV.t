# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
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
]);
