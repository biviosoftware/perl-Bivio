# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..10\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Type::DateInterval;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
use Bivio::Type::Date;
use Bivio::Type::Time;

my($T) = 2;

sub make_date {
    return shift(@_).' '.Bivio::Type::DateTime::DEFAULT_TIME();
}
sub make_time {
    return Bivio::Type::DateTime::DEFAULT_DATE().' '.shift(@_);
}
my(@tests) = (
    MONTH => [
	inc => [
	    '1/1/1911' => '2/1/1911',
	    '1/31/2000' => '2/29/2000',
	],
	dec => [
	    '1/1/1911' => '12/1/1910',
	    '2/29/2000' => '1/29/2000',
	    '7/31/2000' => '6/30/2000',
	],
    ],
    YEAR => [
	inc => [
	    '1/1/1911 12:12:13' => '1/1/1912 12:12:13',
	    '2/29/2000' => '2/28/2001',
	],
	dec => [
	    '1/1/1911 12:12:13' => '1/1/1910 12:12:13',
	    '2/29/2000' => '2/28/1999',
	],
    ],
);

while (@tests) {
    my($interval, $interval_tests) = splice(@tests, 0, 2);
    foreach my $interval_test (@$interval_tests) {
	my($op, $op_tests) = splice(@$interval_tests, 0, 2);
	while (@$op_tests) {
	    t($interval, $op, splice(@$op_tests, 0, 2));
	}
    }
}

sub t {
    my($interval, $op, $date_time, $expected) = @_;
    $date_time = _convert($date_time);
    $expected = _convert($expected);
    my($actual) = Bivio::Type::DateInterval->$interval()->$op($date_time);
    if ($actual eq $expected) {
	print "ok ", $T++, "\n";
	return;
    }
    print "not ok ", $T++,  " $interval\->$op\(",
	    Bivio::Type::DateTime->to_string($date_time),
	    ") -> ",
	    Bivio::Type::DateTime->to_string($actual),
	    " (expected ",
	    Bivio::Type::DateTime->to_string($expected),
	    ")\n";
}

sub _convert {
    my($input) = @_;
    my($date, $time) = split(' ', $input);
    return Bivio::Type::DateTime->from_parts(
	    (Bivio::Type::DateTime->to_parts(
		    Bivio::Type::Time->from_literal_or_die(
			    $time || '0:0:0')))[0,1,2],
	    (Bivio::Type::DateTime->to_parts(
		    Bivio::Type::Date->from_literal_or_die($date)))[3,4,5]);
}
