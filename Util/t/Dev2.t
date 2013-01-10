# Copyright (c) 2013 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
BEGIN {
    $| = 1;
    print "1..2\n";
}
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
BEGIN {
    $ENV{BCONF} = 'Bivio::PetShop::BConf';
}
use Bivio::Util::Dev;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;
print Bivio::Util::Dev->bashrc_b_env_aliases
    eq q[function b_env { eval $(b-env "$@") && b_ps1 $1; } ;
alias b_pet='b_env pet Bivio/PetShop']
    ? "ok $T\n" : "not ok $T\n";

1;
