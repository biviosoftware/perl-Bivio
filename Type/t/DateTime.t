# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..49\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::Type::Time;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;

my(@tests) = (
    'Bivio::Type::DateTime', {
    	get_min => 0,
	get_max => 2147483647,
	get_precision => 10,
	get_width => 10,
	get_decimals => 0,
	can_be_zero => 1,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '9' => 9,
	    '1000000000' => 1000000000,
	    '-9' => undef,
	],
    },
    'Bivio::Type::Date', {
    	get_min => Bivio::Type::DateTime::DEFAULT_TIME(),
	get_max => 2147472000 + Bivio::Type::DateTime::DEFAULT_TIME(),
	get_precision => 10,
	get_width => 10,
	get_decimals => 0,
	can_be_zero => 0,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '1/1/1970' => Bivio::Type::DateTime::DEFAULT_TIME(),
	    '1/1/1970 x' => undef,
	    '1/2/1970' => Bivio::Type::DateTime::SECONDS_IN_DAY()
	        + Bivio::Type::DateTime::DEFAULT_TIME(),
	    '12/31/2037' => 2145830400
	        + Bivio::Type::DateTime::DEFAULT_TIME(),
	    '12/32/2037' => undef,
	    '0/1/2037' => undef,
	    '1/1/2038' => undef,
	    '1/1/1969' => undef,
	],
    },
    'Bivio::Type::Time', {
    	get_min => 0,
	get_max => (23 * 60 + 59) * 60 + 59,
	get_precision => 5,
	get_width => 13,
	get_decimals => 0,
	can_be_zero => 1,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '1:1:1' => (1 * 60 + 1) * 60 + 1,
	    '24:0:0' => 0,
	    '24:0:0 x' => undef,
	    '24:0:0 ax' => undef,
	    '24:0:1' => undef,
	    '24:1:0' => undef,
	    '12:59:0 p.m.' => (12 * 60 + 59) * 60 + 0,
	    '12:59:0  a' => (0 * 60 + 59) * 60 + 0,
	    '1:0:0  a' => (1 * 60 + 0) * 60 + 0,
	    '1:0:1  p' => (13 * 60 + 0) * 60 + 1,
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
    my($actual, $error) = $class->$method($case);
    (print "ok ", $T++, "\n"), return if defined($actual) == defined($expected)
	    && (!defined($actual) || $actual eq $expected);
    print "not ok ", $T++,  " $class\->$method\(",
	    defined($case) ? $case : '<undef>', "\) = ",
	    defined($actual) ? $actual : '<undef>',
	    ', ',
	    defined($error) ? $error->get_name : '<undef>',
	    "\n";
}
