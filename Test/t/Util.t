# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
#
# Only works in PetShop config.
#
use Bivio::Test;
use Bivio::Test::Util;
use File::Spec ();
-r ($ENV{ORIGINAL_BCONF} = $ENV{BCONF}) || die('$BCONF must be set');
$ENV{BCONF} = File::Spec->rel2abs('Util.bconf');
Bivio::IO::File->chdir('Util');
Bivio::Test->unit([
    Bivio::Test::Util->new => [
	# Needs to be first for initialization of Facade
	task => [
	    MAIN => qr/REPTILES/,
	    ['PRODUCTS', 'p=REPTILES'] => qr/iguana.*rattlesnake/is,
	],
	unit => [
	    ['should-pass.t'] => [],
	    ['should-fail.t-data'] => Bivio::DieCode->DIE,
	    ['.'] => [],
	],
	acceptance => [
	    ['should-pass.btest'] => [],
	    ['should-fail.btest-data'] => Bivio::DieCode->DIE,
	    ['.'] => [],
	],
     ],
]);
