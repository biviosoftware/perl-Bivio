# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
use strict;
use Bivio::IO::Config;
use Bivio::Agent::HTTP::Cookie;
use Bivio::Test;
use Bivio::Test::Request;
use Bivio::Type::UserAgent;
use Bivio::Test::Bean;
Bivio::IO::Config->introduce_values({
    'Bivio::IO::ClassLoader' => {
	delegates => {
	    'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::PersistentCookie',
	},
    },
    'Bivio::Delegate::PersistentCookie' => {
	# Can't test with a domain (FakeRequest is too simple),
	# but not a big problem.
	domain => undef,
	tag => 'TT',
    },
});
my($_req) = Bivio::Test::Request->get_instance;
Bivio::Type::UserAgent->put_on_request('', $_req);
my($_r) = Bivio::Test::Bean->new;
Bivio::Test->new({
    method_is_autoloaded => 1,
})->unit([
    Bivio::Agent::HTTP::Cookie->new($_req, $_r) => [
	put => [
	    [x1 => 'v1', x2 => 'v2'] => undef,
        ],
	header_out => [
	    [$_r, $_req] => 1,
        ],
    ],
    $_r => [
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
	    [$_req, $_r] => sub {
		my($case, $return) = @_;
		return $return->[0]->get('x1') eq 'v1';
	    },
        ],
    ],
]);

