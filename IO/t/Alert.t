# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..2\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::Alert;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

print STDERR "\n";

Bivio::IO::Alert->warn("this is a warning");

eval {
    Bivio::IO::Alert->bootstrap_die("bye");
};

print "ok 2\n";
