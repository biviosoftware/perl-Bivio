# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..1\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::Alert;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.


warn("this is a warning");
die("bye");