# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
Bivio::Test->new('Bivio::IO::Ref')->unit([
    'Bivio::IO::Ref' => [
	to_string => [
	    [['a']] => [\<<'EOF'],
[
  'a'
]
EOF
	    # Assumes the Data::Dumper algorithm
	    [{a0 => '0', b => ['b', 'c']}] => [\<<'EOF'],
{
  'a0' => '0',
  'b' => [
    'b',
    'c'
  ]
}
EOF
	],
	nested_differences => [
	    [undef, undef] => [undef],
	    [undef, 'b'] => [\("<undef> != b")],
	    ['a', undef] => [\("a != <undef>")],
            [['a'], {a => '0'}] => [\("[a] != {a=>0}")],
            ['a', 'b'] => [\("a != b")],
            [['a', 'b'], ['a']] =>
                [\("2 != 1 at ->scalar()\nb != <undef> at ->[1]")],
            [['a', ['b']], ['a', 'c']] => [\("[b] != c at ->[1]")],
            [['a', 'b'], ['c', 'd']] => [\(
		"a != c at ->[0]\nb != d at ->[1]"
	    )],
            [\('a'), \('b')] => [\("a != b at ->")],
            [{'a' => 1}, {'b' => 1}] => [\("a != b at ->keys()->[0]")],
            [{'a' => 1}, {'a' => 2}] => [\("1 != 2 at ->{'a'}")],
            [{'a' => 1, 'b' => 2}, {'a' => 2, 'b' => 3}] => [\(
		"1 != 2 at ->{'a'}\n2 != 3 at ->{'b'}"
	    )],
	    [qr/\d/, 1] => [undef],
	    [qr/abc/, qr/abc/] => [undef],
	    [qr/abc/, qr/abd/] => [\('(?-xism:abc) != (?-xism:abd)')],
	    Bivio::IO::ClassLoader->unsafe_simple_require('Algorithm::Diff')
	        ? ([<<'LEFT', <<'RIGHT'] => [\<<'EOF']) : (),
Line 1 agrees
Second Line is off
Line 3 same
3a is missing
Line 4 same
Line 5 is diff
LEFT
Line 1 agrees
Second Line is on
Line 3 same
Line 4 same
Line 5 is diffX
RIGHT
*** EXPECTED
--- ACTUAL
*** 2,2d2 ***
- Second Line is off
+ Second Line is on
*** 4,4c4,3 ***
- 3a is missing
*** 6,6d5 ***
- Line 5 is diff
+ Line 5 is diffX
EOF
        ],
	nested_contains => [
	    [{a => sub {2}}, {a => 2, b => 1}] => [undef],
	    [{a => sub {shift}}, {a => 3, b => 1}] => [undef],
	    [{a => qr{\d}}, {a => 1, b => 2}] => [undef],
	    [{a => qr{a}}, {a => 1, b => 2}] => q{(?-xism:a) != 1 at ->{'a'}},
	    ['a', \'a'] => [undef],
	    [{a => sub {'1'}}, {a => 2, b => 2}] => q{1 != 2 at ->{'a'}},
	],
    ],
]);
