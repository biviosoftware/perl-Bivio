# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Instrument;

use strict;
use LWP::UserAgent ();
use HTTP::Request ();
$Bivio::Instrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_Attrs);

# Attributes retrieved by this
sub ATTRS () { $_Attrs; }

#RJN: Should we have long names here?
# Maps attribute names to yahoo values
my(%_ATTR_MAP) = (
    '52-week_high' => 'k',
    '52-week_low' => 'j',
    '52-week_range' => 'w',
    'ask' => 'a',
    'average_volume' => 'a2',
    'bid' => 'b',
    'change' => 'c1',
    'change_percent' => 'p2',
    'close' => 'p',
    'currency' => 'c4',
    'day_range' => 'm',
    'dividend_pay_date' => 'r1',
    'dividend_per_share' => 'd',
    'dividend_yield' => 'y',
    'earnings_per_share' => 'e',
    'ex-dividend_date' => 'q',
    'exchange' => 'x',
    'high' => 'h',
    'last_trade_date' => 'd1',
    'last_trade_price' => 'l1',
    'last_trade_time' => 't1',
    'low' => 'g',
    'market_capitalization' => 'j1',
    'name' => 'n',
    'open' => 'o',
    'price_to_earnings' => 'r',
    'shares' => 'j2',
    'symbol' => 's',
    'volume' => 'v',
);


# Shared globals
my($_USER_AGENT) = undef;
my($_REQUEST) = undef;

# An instrument data object is a hash of attributes.

# compile_queury \@attrs -> $query
#   Compiles a query which must be passed to &execute_query
sub compile_query ($) {
    my($attrs) = @_;
    # execute_query needs 'exchange' in attrs to validate symbol
    grep($_ eq 'exchange', @$attrs) || push(@$attrs, 'exchange');
    return {
	'yahoo' => join('', map {
	    defined($_ATTR_MAP{$_}) || die("$_: unknown attribute");
	    $_ATTR_MAP{$_};
	} @$attrs),
# RJN: Make a copy???
	'attrs' => $attrs,
    };
}

# execute_query $proto $query \@symbols -> \@instruments
#   Returns an array of references to Instrument objects for the specified
#   query and symbols.  Only those attributes queried are returned
#   If a symbol is not valid, it will appear as an "undef" in \@instruments.
#   Dies: if error getting data from server or unparseable response
sub execute_query ($$$) {
    my($proto, $query, $symbols) = @_;
    my($class) = ref($proto) || $proto;
    defined($_USER_AGENT) ||			      # Pretend we are Netscape
	(($_USER_AGENT = LWP::UserAgent->new)->agent("Mozilla/3.0"),
	 $_USER_AGENT->timeout(15));
    defined($_REQUEST) || ($_REQUEST = HTTP::Request->new('GET', ''));
    $_REQUEST->uri('http://quote.yahoo.com/d/quote.csv?s='
		   . join('+', @$symbols) . '&f=' . $query->{yahoo});
    my($response) = $_USER_AGENT->request($_REQUEST);
    $response->is_success
        || die($_REQUEST->uri, ': ', $response->status_line, "\n");
    my($line, $instrument, $field);
    my($result) = [];
    foreach $line (split(/\r?\n/, $response->content)) {
	$instrument = {};
	foreach $field (@{$query->{attrs}}) {
	    $line =~ s{^(\"([^\"]*)\"     	   # Matches quoted CSV element
			 |([^\,]*))     	    	     # Matches unquoted
		       (,|$)}{}x 	      # Matches separator or terminator
		|| die($_REQUEST->uri, ': unable to parse: ', $line, "\n");
	    my($v) = defined($2) ? $2 : $3;
	    $instrument->{$field} = $v =~ /\bN\/A\b/ ? undef : $v;
	}
	defined($instrument->{name}) && &adjust_name($instrument->{name});
#RJN: Need a surer way...
	# "Found" means that "exchange" is valid--see compile_query
	# When an exchange is not applicable, the string will be "", not N/A
	push(@$result, defined($instrument->{exchange})
	    ? bless($instrument, $class) : undef);
    }
    return $result;
}

# Adjust the case and eliminate blanks to make it look pretty
sub adjust_name ($) {
    $_[0] =~ s/\b([A-Z])([A-Z]*[AEIOU][A-Z]*)\b/$1\L$2\E/g; 	   # SUN -> Sun
    $_[0] =~ s/\b([AEOIU])([A-Z]+)\b/$1\L$2\E/g; 	  	 # INTL -> Intl
    $_[0] =~ s/\s+$//;				    # yahoo has trailing spaces
}

# attr $instrument $attr $br -> $self->{$attr}
#   Returns named attribute of Instrument
#   Dies: if $attr is undefined
sub attr ($$$) {
    my($self, $attr) = @_;
    exists($self->{$attr}) && return $self->{$attr};
    die($attr, ': unknown attribute');
}

# attrs $instrument -> \@attrs
#   Returns the list of attributes for this instrument
sub attrs ($) {
    return [keys %{shift()}];		  # (shift) required or doesn't compile
}

1;
__END__

=head1 NAME

Bivio::Instrument - Contains attributes of a financial instrument

=head1 SYNOPSIS

  use Bivio::Instrument;

=head1 DESCRIPTION

Retrieves data from quote.yahoo.com via http.  The spreadsheet format
is downloaded.  The output is parsed and broken into named attributes
which can be accessed via C<&attr>.

   a=Ask
   a2=Average Daily Volume
   b=Bid
   c=Change &amp; Percent
   c1=Change
   c2=?Change
   c3=Commission
   c4=*Currency
   d=Dividend/Share
   d1=*Date of Last Trade
   d2=Trade Date
   d3=?Time of Last Trade
   e=Earnings/Share
   f=*More Info
   g=*Low
   g1=Holdings Gain &amp; Percent
   g3=Annualized Gain
   g4=Holdings Gain
   h=High
   i=More Info/*cnsprmi (Information Provider)
   i1=?
   j=*52-Week Low
   j1=Market Capitalization
   j2=*Shares Outstanding
   k=*52-Week High
   l=Last Trade (With Time)
   l1=Last Trade (Price Only)
   l2=High Limit
   l3=Low Limit
   m=Day's Range
   n4=Notes
   n=Name
   o=Open
   p=Previous Close
   p1=Price Paid
   p2=*Change in Percent
   q=Ex-Dividend Date
   q1=Days Change
   q2=*Last Trade Price
   r=P/E Ratio
   r1=Dividend Pay Date
   s=Symbol
   s1=Shares Owned
   t=*Chart URLs (long names: 1year)
   t1=*Time of Last Trade
   u=*Chart URLS (short names: 1y)
   v1=Holdings Value
   v=Volume
   v2=
   w=52-Week Range
   w1=Day's Value Change
   x=Exchange
   y=Dividend Yield
   y1="Time - <b>Last Trade</b>"
   y2="Last Trade"
   z="<tr align=center...>"
   z2="<hr size=0>"

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

=cut
