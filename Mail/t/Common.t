# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::IO::File;
my($sendmail_out) = 'sendmail.tmp';
Bivio::IO::Config->introduce_values({
    'Bivio::Mail::Common' => {
	sendmail => "perl -w mock-sendmail.PL $sendmail_out ",
    },
});
Bivio::Test->new('Bivio::Mail::Common')->unit([
    'Bivio::Mail::Common' => [
	{
	    method => 'send',
	    check_return => sub {
		my($case, $actual, $expect) = @_;
		@$actual = (${Bivio::IO::File->read($sendmail_out)});
		return $expect;
	    },
	} => [
	    ['a@a.a', \(<<'IN'), 0, 'b@b.b'] => <<'OUT',
s: 1

b
IN
From: b@b.b
Recipients: a@a.a
s: 1

b
OUT
	    ['a@a.a', <<'IN', 0] => <<'OUT',
x
IN
Recipients: a@a.a
x
OUT
	    ['a@a.a', <<'IN', 1] => <<'OUT',
zz
IN
Recipients: a@a.a
z
OUT
	],
    ],
]);
