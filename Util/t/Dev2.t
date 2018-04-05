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
    # See IO.Config which checks this var for BCONF mode like this
    $ENV{BIVIO_HTTPD_PORT} = 8000;
    $ENV{BCONF} = 'Bivio::PetShop::BConf';
}
use Bivio::Util::Dev;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;
my($res) = Bivio::Util::Dev->bashrc_b_env_aliases;
# Make this exact, because order and eliminating duplicates matters
print $res eq q[b_env() { eval $(b-env "$@") && b_ps1 $1; } ;
b_project() { b_env project ProjEx; } ;
b_b() { b_env b Bivio; } ;
b_pet() { b_env pet Bivio/PetShop; }]
    ? "ok $T\n" : "not ok $T\n";

1;
