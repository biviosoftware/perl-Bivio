# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::UI::View;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->setup_facade;
die('only works in PetShop facade')
    unless $_req->get('Bivio::UI::Facade')->get('uri') =~ /petshop/;
# For ViewSource widget in PetShop
CORE::system("ln -s . src") unless -e 'src';
Bivio::Test->unit([
    'Bivio::UI::View' => [
	execute => [
	    [Bivio::IO::Ref->to_scalar_ref(<<'EOF'), $_req]
view_class_map('HTMLWidget');
view_main(Page({
    head => Join(['hello']),
    body => Join(['goodbye']),
}));
EOF
	    => sub {
		my($o) = $_req->get('reply')->get_output;
		return $$o =~ /hello.*goodbye/s ? 1 : [$$o];
	    },
            ['main', $_req] => sub {
		return 1;
	    },
	],
    ],
]);
