# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Works best with PetShop from a speed point of view.
#
use Bivio::Mail::Outgoing;
use Bivio::Test::Request;
Bivio::Test->new('Bivio::Test::Request')->unit([
    'Bivio::Test::Request' => [
	initialize_fully => sub {
	    my($case, $actual) = @_;
	    return $actual->[0]->isa('Bivio::Test::Request') ? 1 : 0;
        },
	set_realm_and_user => [
	    demo => undef,
	],
    ],
    sub {
	my($req) = Bivio::Test::Request->get_instance;
	$req->capture_mail;
        my($msg) = Bivio::Mail::Outgoing->new(
            Bivio::Mail::Incoming->new(\(<<'EOF')));
From: Joe Blow <joe@example.com>
To: mary@example.com

What a body!
EOF
        $msg->send;
        return $req;
    } => [
	unsafe_get_captured_mail => qr/From.*What/s,
    ],
]);
