# $Id$
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	Bivio::IO::ClassLoader => {
	    maps => {
		TestLanguage => ['Bivio::Test::t::Language'],
	    },
	},
    });
}
use Bivio::Test;
use Bivio::Test::Language;

Bivio::Test->unit([
    'Bivio::Test::Language' => [
	{
	    method => 'test_run',
	    compute_params => sub {
		my($object, $method, $params) = @_;
		return [\$params->[0]],
	    },
	} => [
	    [<<'EOF'] => [undef],
test_setup('T1', 'x1');
EOF
	    [<<'EOF'] => [undef],
test_setup('T1', 'x2');
die unless double_it('hello') eq 'hellohello'
EOF
	],
    ],
]);
