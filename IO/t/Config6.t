# Copyright (c) 2013 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
# $Id$
use strict;

BEGIN {
    $| = 1;
    print "1..3\n";
}
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
BEGIN {
    delete($ENV{BCONF});
}
use Bivio::IO::Config;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;
print Bivio::IO::Config->bconf_file eq (
    -r '/etc/bivio.bconf' ? '/etc/bivio.bconf'
        : 'Bivio::DefaultBConf->merge'
    ) ? "ok $T\n" : "not ok $T\n";
$T++;
use Bivio::Ext::DBI;
print Bivio::Ext::DBI->get_config->{database} eq 'none'
    ? "ok $T\n" : "not ok $T\n";
$T++;

1;
