# -*-perl-*-
#
# $Id$
#
# Usage:
#	perl -w CreateUserForm.t [display_name:first:middle:last...]
#
use strict;

BEGIN { $| = 1; print "1..22\n"; }
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
    ['Mary J. Keene, M.D.', 'Mary:J.:Keene, M.D.'],
    ['Mary Krueger, R.N.', 'Mary::Krueger, R.N.'],
    ['Rob de la Roche', 'Rob::de la Roche'],
    ['Ludwig von Beethoven', 'Ludwig::von Beethoven'],
    ['Rev. H. Gross', 'Rev. H.::Gross'],
    ['Drew A. Barrymore', 'Drew:A.:Barrymore'],
    ['King James III', 'King::James, III'],
    ['Joe Gross, JD', 'Joe::Gross, JD'],
    ['Mrs. Fiona A. Brydy', 'Mrs. Fiona:A.:Brydy'],
    ['Dr. A. Carter MD', 'Dr. A.::Carter, MD'],
    ['Dr. Richards', 'Dr.::Richards'],
    ['Miss Missy M. Mistletoe, M.S.', 'Miss Missy:M.:Mistletoe, M.S.'],
    ['Joe', '::Joe'],
    ['Jones Sr', '::Jones, Sr'],
    ['A.B. Gross', 'A.:B.:Gross'],
    ['IM ALL CAPS', 'IM:ALL:CAPS'],
    ['Mr.Eric R. Du Puis', 'Mr. Eric:R.:Du Puis'],
    ['Juan Chuy de Marcos', 'Juan:Chuy:de Marcos'],
    ['Maggie de la Rosa', 'Maggie::de la Rosa'],
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

sub _concat{
    my(@n) = @_;
    my($res) = '';
    foreach my $n (@n) {
	$res .= $n if defined($n);
	$res .= ':';
    }
    chop($res);
    return $res;
}
