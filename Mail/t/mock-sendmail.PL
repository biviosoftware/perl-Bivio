#!perl
use strict;
use Bivio::IO::File;
my($out) = shift(@ARGV);
my($res) = '';
$res .= 'From: ' . shift(@ARGV) . "\n"
    if $ARGV[0] =~ s/^-f//;
$res .= 'Recipients: ' . shift(@ARGV) . "\n" . join('', <>);
Bivio::IO::File->write($out, \$res);
