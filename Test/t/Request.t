# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Works best with PetShop from a speed point of view.
#
use Bivio::Test::Request;
Bivio::Test->new('Bivio::Test::Request')->unit([
    sub {
	my($req) = Bivio::Test::Request->get_instance;
	$req->capture_mail;
	my($msg) = Bivio::Mail::Message->new(\(<<'EOF'));
From: Joe Blow <joe@blow.com>
To: mary@com.com

What a body!
EOF
        $msg->send;
        return $req;
    } => [
	unsafe_get_captured_mail => qr/From.*What/s,
    ],
]);
