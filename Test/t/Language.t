# $Id$
use Bivio::Test;
use Bivio::Test::Language;
Bivio::IO::Config->introduce_values({
    Bivio::IO::ClassLoader => {
	maps => {
	    TestLanguage => ['Bivio::Test::t::Language'],
	},
    },
});
Bivio::Test->unit([
    'Bivio::Test::Language' => [
	{
	    method => 'test_run',
	    compute_params => sub {
		my($case, $params) = @_;
		return [\$params->[0]],
	    },
	} => [
	    map({
		[$_] => [undef],
	    }
		q{
		    test_setup('T1', 'x1');
		}, q{
		    test_setup('T1', 'x2');
		    die unless double_it('hello') eq 'hellohello'
		}, q{
		    test_setup('T1', 'x3');
		    test_deviance();
		    die_now();
		}, q{
		    test_setup('T1', 'x4');
		    test_deviance('DIE: you gravy sucking pig');
		    die_now();
		},
	    ),
	    [q{
                test_setup('T1', 'x5');
                die_now();
            }] => qr/Bivio::Die/s,
	    [q{
                test_setup('T1', 'x6');
                test_deviance('NO WAY');
                die_now();
            }] => qr/Bivio::Die.*not match pattern:.*NO WAY/is,
	],
    ],
]);
