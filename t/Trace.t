# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..4\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Trace;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.


# register: Deviance
print eval {
   Bivio::Trace->register;
   1;
} ? "not ok 2\n" : "ok 2\n";

################################################################

package Bivio::Trace::T;

use Bivio::Trace;

Bivio::Trace->register;
print "ok 3\n";

################################################################


