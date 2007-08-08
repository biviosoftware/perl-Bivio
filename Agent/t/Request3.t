# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
BEGIN {
    $| = 1;
    print "1..6\n";
}
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Agent::t::Request::Mock;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my($req) = Bivio::Agent::t::Request::Mock->get_current_or_new;
my($t) = 2;
sub t {
    my($args, $expect) = @_;
    my($actual);
    my($die) = Bivio::Die->catch(sub {
        $actual = $req->redirect($args);
	return;
    });
    print(
	($expect ? $die->get('code')->equals_by_name($expect)
	     : !$die && !$actual) ? "ok $t\n" : "not ok $t\n");
    $t++;
    return;
}
t({task_id => 'LOGIN', method => 'client_redirect'}, 'CLIENT_REDIRECT_TASK');
t({task_id => 'LOGIN', method => 'server_redirect'}, 'SERVER_REDIRECT_TASK');
t({method => 'stop_execute'}, 'DIE');
t({task_id => 'LOGIN', method => 'get'}, 'DIE');
t({}, 'DIE');
