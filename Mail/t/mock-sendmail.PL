#!perl
use strict;
use Bivio::IO::File;
my($out) = shift(@ARGV);
my($fail_marker) = shift(@ARGV);
my($res) = '';
$res .= 'From: ' . shift(@ARGV) . "\n"
    if $ARGV[0] =~ s/^-f//;
$res .= 'Recipients: ' . shift(@ARGV) . "\n" . join('', <>);
exit(1)
    if index($res, $fail_marker) >= 0;
Bivio::IO::File->write($out, \$res);
