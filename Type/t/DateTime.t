# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..78\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::Type::Time;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;

sub make_date {
    return shift(@_).' '.Bivio::Type::DateTime->DEFAULT_TIME;
}
sub make_time {
    return Bivio::Type::DateTime->DEFAULT_DATE.' '.shift(@_);
}
use Bivio::Agent::Request;
Bivio::Agent::Request->get_current_or_new->put(
	timezone => 120);
my(@tests) = (
    'Bivio::Type::DateTime', {
    	get_min => '2378497 0',
	get_max => '2524593 86399',
	get_precision => undef,
	get_width => 13,
	get_decimals => 0,
	can_be_zero => 0,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '2378497 9' => '2378497 9',
	    '-9' => undef,
	    'Feb 29 0:0:0 MST 1972' => '2441377 0',
	    'Feb 29 13:13:13 XXX 2000' => '2451604 47593',
	    '1972/2/29 0:0:0' => '2441377 0',
	    '2000/2/29 13:13:13' => '2451604 47593',
	],
	from_local_literal => [
	    undef, undef,
	    '2378497 9' => '2378497 7209',
	    '-9' => undef,
	    'Feb 29 0:0:0 MST 1972' => '2441377 7200',
	    'Feb 29 13:13:13 XXX 2000' => '2451604 54793',
	    '1972/2/29 0:0:0' => '2441377 7200',
	    '2000/2/29 13:13:13' => '2451604 54793',
	],
	to_string => [
	    '2378497 9' => '01/01/1800 00:00:09 GMT',
	    '2441377 0' => '02/29/1972 00:00:00 GMT',
	    '2451604 47593' => '02/29/2000 13:13:13 GMT',
	],
	to_local_string => [
	    '2378497 7209' => '01/01/1800 00:00:09',
	    '2441377 7200' => '02/29/1972 00:00:00',
	    '2451604 54793' => '02/29/2000 13:13:13',
	],
	to_parts => [
	    Bivio::Type::DateTime->get_min => '0 0 0 1 1 1800',
	    Bivio::Type::DateTime->get_max => '59 59 23 31 12 2199',
	    '2440588 0' => '0 0 0 1 1 1970',
	    '2441377 0' => '0 0 0 29 2 1972',
	    '2451604 47593' => '13 13 13 29 2 2000',
	],
	add_days => [
	    ['2440588 0', 1] => '2440589 0',
	    ['2440588 0', -1] => '2440587 0',
	],
	add_seconds => [
	    ['2440588 0', 1] => '2440588 1',
	    ['2440588 0', 86401] => '2440589 1',
	    ['2440588 0', -86401] => '2440586 86399',
	    ['2440588 0', -1] => '2440587 86399',
	],
    },
    'Bivio::Type::Date', {
    	get_min => '2378497 '.Bivio::Type::DateTime->DEFAULT_TIME,
	get_max => (2524594 - 1).' '.Bivio::Type::DateTime->DEFAULT_TIME,
	get_precision => undef,
	get_width => 10,
	get_decimals => 0,
	can_be_zero => 0,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '1/1/1800' => make_date(2378497),
	    '1/1/1970 x' => undef,
	    '1/1/1850' => make_date(2396759),
	    '1/2/1800' => make_date(2378498),
	    '1/1/1900' => make_date(2415021),
	    '1/1/1970' => make_date(
		    Bivio::Type::DateTime::UNIX_EPOCH_IN_JULIAN_DAYS()),
	    '1/1/1900' => make_date(2415021),
	    '1/1/2000' => make_date(2451545),
	    '1/1/2100' => make_date(2488070),
	    '12/31/2199' => make_date(2524593),
	],
    },
    'Bivio::Type::Time', {
    	get_min => '2378497 0',
	get_max => '2378497 '.((23 * 60 + 59) * 60 + 59),
	get_precision => undef,
	get_width => 13,
	get_decimals => 0,
	can_be_zero => 0,
	can_be_positive => 1,
	can_be_negative => 0,
	from_literal => [
	    undef, undef,
	    '1:1:1' => make_time((1 * 60 + 1) * 60 + 1),
	    '24:0:0' => make_time(0),
	    '24:0:0 x' => undef,
	    '24:0:0 ax' => undef,
	    '24:0:1' => undef,
	    '24:1:0' => undef,
	    '12:59:0 p.m.' => make_time((12 * 60 + 59) * 60 + 0),
	    '12:59:0  a' => make_time((0 * 60 + 59) * 60 + 0),
	    '1:0:0  a' => make_time((1 * 60 + 0) * 60 + 0),
	    '1:0:1  p' => make_time((13 * 60 + 0) * 60 + 1),
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
    my($actual, $error) =  $method eq 'to_parts'
	    ? join(' ', $class->$method($case))
		    : $class->$method(ref($case) ? @$case : $case);
    if (defined($actual) == defined($expected)
	    && (!defined($actual) || $actual eq $expected)) {
	print "ok ", $T++, "\n";
	return;
    }
    print "not ok ", $T++,  " $class\->$method\(",
	    defined($case) ? (ref($case) ? join(', ', @$case) : $case)
		    : '<undef>', "\) = ",
	    defined($actual) ? $actual : '<undef>',
	    ', expected=', defined($expected) ? $expected : '<undef>',
	    defined($error) ? (', ', $error->get_name) : '',
	    "\n";
}
