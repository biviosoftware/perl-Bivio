# Copyright (c) 2008 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
BEGIN { $| = 1; print "1..2\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
BEGIN {
    @main::ARGV = '--TRACE=sql';
}
use Bivio::IO::ClassLoader;
Bivio::IO::ClassLoader->simple_require('Bivio::IO::Trace');
$loaded = 1;
print "ok 1\n";
######################### End of black magic.
# Verify that method is defined.
_trace();

print Bivio::IO::Trace->get_call_filter eq '$sub =~ /_trace_sql/'
    ? 'ok 2' : 'not ok 2',
    "\n";
