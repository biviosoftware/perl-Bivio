# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..19\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::Email;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;

my(@tests) = (
    'Bivio::Type::Email', {
	from_literal => [
	    undef, undef,
	    '', undef,
	    'x@y.z' => 'x@y.z',
	    'x@y:.z', undef,
	    'ignore-x@y.z', 'ignore-x@y.z',
	],
	is_valid => [
	    undef, 0,
	    '', 0,
	    'x@y.z', 1,
	    'x@y:.z', 0,
	    'ignore-x@y.z', 1,
	],
	is_ignore => [
	    undef, 1,
	    '', 1,
	    'x@y.z', 0,
	    'x@y:.z', 1,
	    'ignore-x@y.z', 1,
	],
	to_xml => [
	    'ignore-foo@a.a' => '',
	    [undef] => '',
	    'a@a.a' => 'a@a.a',
	],
    },
);

while (@tests) {
    my($class, $tests) = (shift(@tests), shift(@tests));
    foreach my $method (sort(keys(%$tests))) {
	my($v) = $tests->{$method};
        unless (ref($v)) {
	    t($class, $method, undef, $v);
	    next;
	}
	my(@v) = @$v;
	while (@v) {
	    my($case, $res) = (shift(@v), shift(@v));
	    t($class, $method, $case, $res);
	}
    }
}

sub t {
    my($class, $method, $case, $expected) = @_;
    my($actual) = $class->$method($case);
    (print "ok ", $T++, "\n"), return if defined($actual) == defined($expected)
	    && (!defined($actual) || $actual eq $expected);
    print "not ok ", $T++,  " $class\->$method\(",
	    defined($case) ? $case : '<undef>', "\) = ",
		    defined($actual) ? $actual : '<undef>', "\n";
}
