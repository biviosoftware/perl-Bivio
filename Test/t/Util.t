# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
#
# Only works in PetShop config.
#
BEGIN {
    push(@ARGV, "--Bivio::Test::t::Language::T1.t1='foo'");
}
use Bivio::Test;
use Bivio::Test::Util;
use Bivio::Test::Language::HTTP;
use File::Spec ();
Bivio::IO::Config->introduce_values({
    'Bivio::Test::Language::HTTP' => {
	# This port won't exist so mock_sendmail will fail quickly
	home_page_uri => 'http://localhost:1',
	mail_tries => 5,
     },
});
-r ($ENV{ORIGINAL_BCONF} = $ENV{BCONF}) || die('$BCONF must be set');
$ENV{BCONF} = File::Spec->rel2abs('Util.bconf');
Bivio::IO::File->chdir('Util');
my($user) = "$ENV{USER}\@localhost.localdomain";
Bivio::Test->unit([
    'Bivio::Test::Language::HTTP' => [
	handle_setup => undef,
    ],
    'Bivio::Test::Util' => [
	main => [
	    [
		'-input' => \(<<"EOF"),
From: Joe <$user>
To: Joe <$ENV{USER}+btest_bla\@localhost.localdomain>
Subject: my subject

First message.
EOF
		'mock_sendmail',
		"-f$user",
		"$ENV{USER}+btest_bla\@localhost.localdomain",
	    ] => undef,
	    [
		'-input' => \(<<"EOF"),
From: Joe <$ENV{USER}+btest_bounce\@localhost.localdomain>
To: Joe <no-such-user\@localhost.localdomain>
Subject: my subject

Second message.
EOF
		'mock_sendmail',
		"no-such-user\@localhost.localdomain",
	    ] => undef,
	],
    ],
    'Bivio::Test::Language::HTTP' => [
	handle_setup => undef,
	verify_local_mail => [
	    ["$ENV{USER}+btest_bla\@localhost.localdomain", qr{First message.}i] => undef,
	    # Want to make sure hits procmail
	    ["$ENV{USER}+btest_bounce\@localhost.localdomain", qr{internal error}i] => undef,
	],
    ],
    Bivio::Test::Util->new => [
	# Needs to be first for initialization of Facade
	task => [
	    MAIN => qr/REPTILES/,
	    ['PRODUCTS', 'p=REPTILES'] => qr/iguana.*rattlesnake/is,
	],
	unit => [
	    ['should-pass.t'] => [],
	    ['subdir-pass.t'] => [],
	    ['should-fail.t-data'] => Bivio::DieCode->DIE,
	    ['.'] => [],
	],
	acceptance => [
	    ['should-pass.btest'] => [],
	    ['should-fail.btest-data'] => Bivio::DieCode->DIE,
	    ['.'] => [],
	],
    ],
]);
