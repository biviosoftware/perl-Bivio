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
  'b' => [
    'b',
    'c'
  ],
  'a0' => '0'
}
EOF
	],
	nested_differences => [
	    [undef, undef] => [undef],
	    [undef, 'b'] => [\("undef != 'b'")],
	    ['a', undef] => [\("'a' != undef")],
            [['a'], {a => '0'}] => [\("['a'] != {'a' => '0'}")],
            ['a', 'b'] => [\("'a' != 'b'")],
            [['a', 'b'], ['a']] => [\("2 != 1 at ->scalar()")],
            [['a', ['b']], ['a', 'c']] => [\("['b'] != 'c' at ->[1]")],
            [['a', 'b'], ['c', 'd']] => [\(
		"'a' != 'c' at ->[0]\n'b' != 'd' at ->[1]"
	    )],
            [\('a'), \('b')] => [\("'a' != 'b' at ->")],
            [{'a' => 1}, {'b' => 1}] => [\("'a' != 'b' at ->keys()->[0]")],
            [{'a' => 1}, {'a' => 2}] => [\("1 != 2 at ->{'a'}")],
            [{'a' => 1, 'b' => 2}, {'a' => 2, 'b' => 3}] => [\(
		"1 != 2 at ->{'a'}\n2 != 3 at ->{'b'}"
	    )],
	    [qr/abc/, qr/abc/] => [undef],
	    [qr/abc/, qr/abd/] => [\('qr/(?-xism:abc)/ != qr/(?-xism:abd)/')],
	],
    ],
]);
