# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..14\n"; }
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

my($_PRINTED);
my($_TEST) = 4;
sub _printer {
   $_PRINTED = join('', @_);
}
Bivio::Trace->set_printer(\&_printer);

sub _hit {
   $_PRINTED = undef;
   my($msg) = join('', @_);
   &_trace($msg);
   print $_PRINTED =~ /$msg/ ? "ok $_TEST\n" : "not ok $_TEST\n";
   $_TEST++;
}

sub _miss {
   $_PRINTED = undef;
   &_trace(@_);
   print defined($_PRINTED) ? "not ok $_TEST\n" : "ok $_TEST\n";
   $_TEST++;
}

Bivio::Trace->set_filters('grep($_ =~ "hello", @$msg)');
&_hit("hello");
&_miss("goodbye");

Bivio::Trace->set_filters(undef, '/' . __PACKAGE__ . '/');
&_hit("anything");

Bivio::Trace->set_filters();
&_miss("anything");

Bivio::Trace->set_filters('$pkg eq "' . __PACKAGE__ . '"');
&_hit("anything");

Bivio::Trace->set_filters('$line < 100');
&_hit("anything");

Bivio::Trace->set_filters('$line > 100');
&_miss("anything");

Bivio::Trace->set_filters('$sub eq "Bivio::Trace::T::_hit"');
&_hit("anything");
&_miss("anything");

Bivio::Trace->set_filters('$file =~ /Trace.t/');
&_hit("anything");

Bivio::Trace->set_filters('$file =~ /Trace.pm/');
&_miss("anything");
