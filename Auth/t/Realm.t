# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..6\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Auth::Realm;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

package Bivio::Auth::Realm::T1;

use Bivio::Auth::Realm;
use Bivio::Agent::TaskId;
use Bivio::Auth::Role;
@Bivio::Auth::Realm::T1::ISA = qw(Bivio::Auth::Realm);

my(%_TASK_ID_TO_ROLE) = map {
    my($t, $r) = split(/:/);
    (Bivio::Agent::TaskId->$t(), Bivio::Auth::Role->$r())
} (
    'SETUP_INTRO:ANONYMOUS',
    'SETUP_USER_CREATE:USER',
);

sub new {
    my($proto) = @_;
    return &Bivio::Auth::Realm::new($proto, \%_TASK_ID_TO_ROLE);
}

package main;

my($t1) = Bivio::Auth::Realm::T1->new();
print $t1->get_user_role(undef) eq Bivio::Auth::Role::ANONYMOUS()
	? "ok 2\n" : "not ok 2\n";
print $t1->can_role_execute_task(Bivio::Auth::Role::ANONYMOUS(),
	Bivio::Agent::TaskId::SETUP_INTRO) ? "ok 3\n" : "not ok 3\n";
print $t1->can_role_execute_task(Bivio::Auth::Role::USER(),
	Bivio::Agent::TaskId::SETUP_INTRO) ? "ok 4\n" : "not ok 4\n";
print $t1->can_role_execute_task(Bivio::Auth::Role::ANONYMOUS(),
	Bivio::Agent::TaskId::SETUP_USER_CREATE) ? "not ok 5\n" : "ok 5\n";
print $t1->can_role_execute_task(Bivio::Auth::Role::USER(),
	Bivio::Agent::TaskId::SETUP_USER_CREATE) ? "ok 6\n" : "not ok 6\n";
