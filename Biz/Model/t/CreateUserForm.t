# -*-perl-*-
#
# $Id$
#
# Usage:
#	perl -w CreatUserForm.t [display_name:first:middle:last...]
#
use strict;

BEGIN { $| = 1; print "1..3\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Biz::Model::CreateUserForm;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($T) = 2;

# Get names:results from command line or from list of standard tests.
my(@names) = @ARGV
	? map {[split(/:/, $_, 2)]} @ARGV
	: (
    # Syntax: [display_name, expected first:middle:last]
    ['Dr. John', 'Dr.::John'],
    ['Hot, Dog', 'Dog::Hot'],
);

my(@fields) = qw(
    User.first_name
    User.middle_name
    User.last_name
);
my($req) = Bivio::Agent::Request->get_current_or_new;
foreach my $name (@names) {
    # This interface is fragile, but works for testing...
    my($cuf) = Bivio::Biz::Model::CreateUserForm->new($req);
    my($dn) = shift(@$name);
    $cuf->internal_put_field('RealmOwner.display_name', $dn);
#TODO: "properties" should be deprecated
    $cuf->parse_display_name($cuf, $cuf->get_shallow_copy);
    my($actual) = _concat($cuf->get(@fields));
    my($expected) = shift(@$name);
    print $actual eq $expected ? ("ok ", $T++, "\n")
	    : ("not ok ", $T++, " (expected) ", $expected, ' != ',
		    $actual, " (actual)\n");
}

sub _concat {
    my(@n) = @_;
    my($res) = '';
    foreach my $n (@n) {
	$res .= $n if defined($n);
	$res .= ':';
    }
    chop($res);
    return $res;
}
