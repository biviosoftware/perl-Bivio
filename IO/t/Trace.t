# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..13\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::Trace;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

package Bivio::IO::Trace::T;

use Bivio::IO::Trace;

Bivio::IO::Trace->register;
print "ok 2\n";

################################################################

my($_PRINTED);
my($_TEST) = 3;
sub _printer {
   $_PRINTED = join('', @_);
}
Bivio::IO::Trace->set_printer(\&_printer);

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

Bivio::IO::Trace->set_filters('grep($_ =~ /hello/, @$msg)');
&_hit("hello");
&_miss("goodbye");

Bivio::IO::Trace->set_filters(undef, '/' . __PACKAGE__ . '/');
&_hit("anything");

Bivio::IO::Trace->set_filters();
&_miss("anything");

Bivio::IO::Trace->set_filters('$pkg eq "' . __PACKAGE__ . '"');
&_hit("anything");

Bivio::IO::Trace->set_filters('$line < 100');
&_hit("anything");

Bivio::IO::Trace->set_filters('$line > 100');
&_miss("anything");

Bivio::IO::Trace->set_filters('$sub eq "Bivio::IO::Trace::T::_hit"');
&_hit("anything");
&_miss("anything");

Bivio::IO::Trace->set_filters('$file =~ /Trace.t/');
&_hit("anything");

Bivio::IO::Trace->set_filters('$file =~ /Trace.pm/');
&_miss("anything");
