# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..28\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::Integer;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;

my(@tests) = (
    'Bivio::Type::Integer', {
    	get_min => -999999999,
	get_max => 999999999,
	get_precision => 9,
	get_width => 10,
	get_decimals => 0,
	can_be_zero => 1,
	can_be_positive => 1,
	can_be_negative => 1,
	from_literal => [
	    undef, undef,
	    '00009' => '9',
	    '+00009' => '9',
	    '-00009' => '-9',
	    '-99999999999999' => undef,
	    '-00000000000009' => '-9',
	    '+00000000000009' => '9',
	],
    },
    Bivio::Type::Integer->new(1,10), {
    	get_min => 1,
	get_max => 10,
	get_precision => 2,
	get_width => 2,
	get_decimals => 0,
	can_be_zero => 0,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '00009' => '9',
	    '+00009' => '9',
	    '-00009' => undef,
	    '0' => undef,
	    '11' => undef,
	    '-00000000000009' => undef,
	    '+00000000000009' => '9',
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
	foreach (@v) {
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
