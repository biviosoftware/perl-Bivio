use Bivio::Test;
use Bivio::Test::Util;
use File::Spec ();
-r ($ENV{ORIGINAL_BCONF} = $ENV{BCONF}) || die('$BCONF must be set');
$ENV{BCONF} = File::Spec->rel2abs('Util.bconf');
Bivio::IO::File->chdir('Util');
Bivio::Test->unit([
    Bivio::Test::Util->new => [
	unit => [
	    ['should-pass.t'] => [],
	    ['should-fail.t'] => Bivio::DieCode->DIE,
	    ['.'] => Bivio::DieCode->DIE,
	],
	acceptance => [
	    ['should-pass.btest'] => [],
	    ['should-fail.btest'] => Bivio::DieCode->DIE,
	    ['.'] => Bivio::DieCode->DIE,
	],
     ],
]);
