# -*-perl-*-
#
# $Id$
#
use strict;
BEGIN { $| = 1; print "1..4\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Instrument;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub test ($$) {
    my($query) = &Bivio::Instrument::compile_query(shift);
    my($syms) = shift;
    my($instruments) = Bivio::Instrument->execute_query($query, $syms);
    my($i, $a);
    foreach $i (0 .. $#{$syms}) {
	print $syms->[$i], "\n";
	my($instrument) = $instruments->[$i];
	foreach $a (@{$instrument->attrs}) {
	    printf("%24s %s\n", $a,
		   defined($instrument->attr($a))
		   ? $instrument->attr($a) : '');
	}
    }
}

print "Testing various symbols...\n";
&test([qw(symbol close)], [sort qw(ibm sunw msft javlx ^dji vts ewj xle)]);
print "ok 2\n";
print "Testing all attributes...\n";
&test([qw(
    52-week_high
    52-week_low
    52-week_range
    ask
    average_volume
    bid
    change
    change_percent
    close
    currency
    day_range
    dividend_pay_date
    dividend_per_share
    dividend_yield
    earnings_per_share
    ex-dividend_date
    exchange
    high
    last_trade_date
    last_trade_price
    last_trade_time
    low
    market_capitalization
    name
    open
    price_to_earnings
    shares
    symbol
    volume
)], [qw(ibm ^dji javlx ewj)]);
print "ok 3\n";
print "Testing NO-SUCH-SYMBOL...\n";
my($instruments) = Bivio::Instrument->execute_query(
    &Bivio::Instrument::compile_query(['symbol']), ['NO-SUCH-SYMBOL']);
print (defined($instruments->[0]) ? "not ok 4\n" : "ok 4\n");
