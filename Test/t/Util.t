use Bivio::Test;
use Bivio::Test::Util;
Bivio::IO::File->chdir('Util');
Bivio::Test->unit([
    Bivio::Test::Util->new => [
	unit => [
	    ['u1.t'] => [],
	    ['u2.t'] => Bivio::DieCode->DIE,
	    ['.'] => Bivio::DieCode->DIE,
	],
     ],
]);
