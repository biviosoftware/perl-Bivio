# -*-perl-*-
#
# $Id$
#
use strict;

print "1..1\n";
use Bivio::IO::TTY;
print "You need to pass an argument to test this class\n";
my($pass) =
    @ARGV ? Bivio::IO::TTY->read_password('Enter password "hello": ')
    # If not passed arguments, does nothing.
    : 'hello';
print $pass eq 'hello' ? "\nok 1\n" : "\nnot ok 1 ($pass)\n";
