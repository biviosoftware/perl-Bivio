#
# schelle@bivio.com
#
# BivioResponse.pm
#
# Description: Module used to create a BivioResponse, an object which
#              contains the results of parsing an HTTP::Response using
#              BivioParser.pm
#

package BivioResponse;
use strict;

use BivioParser;
use PrintUtils;

#
# Creates instance of a BivioResponse (the parsed HTTP::Response)
#
sub new {
	my($http_res) = shift; # gets HTTP::Response as argument
	my($self) = {};
	bless($self);

	$self = BivioParser->parse_http_response($http_res);

	return $self;
}

1;

