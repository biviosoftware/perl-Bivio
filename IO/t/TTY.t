# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..10\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::TTY;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($pass) = Bivio::IO::TTY->read_password('Enter password "hello": ');
print $pass eq 'hello' ? "\nok 2\n" : "\nnot ok 2 ($pass)\n";
