# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Works best with PetShop from a speed point of view.
#
use Bivio::Test::Request;
Bivio::IO::Config->introduce_values({
    Bivio::Mail::Message => {
	test_mode => 1,
    },
});
my($_REQ) = Bivio::Test::Request->initialize_fully;
Bivio::Test->new('Bivio::Mail::Message')->unit([
    [\(<<'EOF')
From: Joe Blow <joe@blow.com>
To: Mary <mary@contrary.com>
Subject: subjective

What a body!

Signed,
Joe
EOF
    ] => [
	get_field => [
	    'subject' => 'subjective',
        ],
	add_recipients => [
	    'nobody' => [],
	],
	send => [
	    [$_REQ] => [],
	],
	get_tests => [
	    [$_REQ] => sub {
		my($case) = @_;
		return [[$case->get('object')]];
	    },
	],
    ],
]);
