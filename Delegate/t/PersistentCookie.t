# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
use strict;
use Bivio::Agent::HTTP::Cookie;
use Bivio::Test;
use Bivio::Test::Request;
Bivio::IO::Config->introduce_values({
    'Bivio::Delegate::PersistentCookie' => {
	# Can't test with a domain (FakeRequest is too simple),
	# but not a big problem.
	domain => undef,
	tag => 'Tt',
    },
});
my($_req) = Bivio::Test::Request->get_instance->setup_http(
    'Bivio::Delegate::PersistentCookie',
);
Bivio::Test->new({
    method_is_autoloaded => 1,
})->unit([
    Bivio::Agent::HTTP::Cookie->new($_req, $_req->get('r')) => [
	put => [
	    [x1 => 'v1', x2 => 'v2'] => undef,
        ],
	header_out => [
	    [$_req, $_req->get('r')] => 1,
        ],
    ],
    # Checks previous call and sets up for next call
    $_req->get('r') => [
	header_out => sub {
	    my($case, $return) = @_;
	    return 0 unless
		$return->[1] =~ m#^(TT=\S+); path=/; expires=#s;
	    # Save for next test; only call is for "Cookie"
	    $case->get('object')->header_in($1);
	    return 1;
        },
    ],
    'Bivio::Agent::HTTP::Cookie' => [
	new => [
	    [$_req, $_req->get('r')] => sub {
		my($case, $return) = @_;
		return $return->[0]->get('x1') eq 'v1' ? 1 : 0;
	    },
        ],
    ],
]);

