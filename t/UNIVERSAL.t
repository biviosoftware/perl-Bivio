#!perl -w
# $Id$
use strict;
use Bivio::Test;
use Bivio::UNIVERSAL;

package Bivio::t::UNIVERSAL::t1;
$Bivio::t::UNIVERSAL::t1::VERSION = 3.154;

@Bivio::t::UNIVERSAL::t1::ISA = ('Bivio::UNIVERSAL');
my($_IDI1) = __PACKAGE__->instance_data_index;
sub my_idi {
    return $_IDI1;
}

package Bivio::t::UNIVERSAL::t2;
@Bivio::t::UNIVERSAL::t2::ISA = ('Bivio::t::UNIVERSAL::t1');
my($_IDI2) = __PACKAGE__->instance_data_index;
sub my_idi {
    return $_IDI2;
}

Bivio::Test->unit([
    'Bivio::t::UNIVERSAL::t1' => [
	inheritance_ancestor_list => [
	    [] => [[qw(Bivio::UNIVERSAL)]],
	],
	my_idi => 0,
	package_version => 3.154,
    ],
    'Bivio::t::UNIVERSAL::t2' => [
	inheritance_ancestor_list => [
	    [] => [[qw(Bivio::t::UNIVERSAL::t1 Bivio::UNIVERSAL)]],
	],
	my_idi => 1,
    ],
]);

