# $Id$
use Bivio::Test;
use Bivio::Test::HTMLParser;
use Bivio::IO::File;
Bivio::Test->new({
    result_ok => sub {
	my($object, $method, $params, $expect, $actual) = @_;
	return 0 unless ref($actual->[0]) eq 'HASH';
	return $expect->[0] eq $actual->[0]->{href};
    }
})->unit([
    map {(
        Bivio::Test::HTMLParser->new(
	    Bivio::IO::File->read("HTMLParser/$_->[0].html")) => [
		get_nested => $_->[1]
	    ],
    )} [
	login => [
	    ['Links', 'Please Register.', 0] => ['/pub/register'],
	    ['Links', 'help_off', 0] => ['/hp/index.html'],
	],
#    ], [
    ],
]);

