# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Must be executed in the petshop facade.
#
use strict;
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Auth::Permission'
		    => 'Bivio::Delegate::t::Mock::Permission',
	    },
        },
    });
}
use Bivio::PetShop::Test::Request;
my($req) = Bivio::PetShop::Test::Request->initialize_fully;
Bivio::Test->unit([
    $req => [
	{
	    method => 'can_user_execute_task',
	    compute_params => sub {
		my(undef, $params) = @_;
		$req->set_realm($params->[1]);
		if ($params->[2] && $params->[2] =~ s/^su_//) {
		    $req->set_user('root');
		    Bivio::Biz::Model->new($req, 'UserLoginForm')
		        ->substitute_user(Bivio::Biz::Model->new(
			    $req, 'RealmOwner')->unauth_load_or_die({
				name => $params->[2],
			    }),
			    $req,
			);
		} else {
		    $req->set_user($params->[2]);
		}
		return [Bivio::Agent::TaskId->from_name($params->[0])];
	    },
	} => [
	    map({
		my($t, @e) = @$_;
		my($r) = $t =~ /^USER/ ? 'demo' : undef;
		map({
		    ([$t, $r, $_] => shift(@e));
		} undef, 'demo', 'root');
	    }
		[SITE_ROOT => 1, 1, 1],
		[ADM_SUBSTITUTE_USER => 0, 0, 1],
		[USER_ACCOUNT_EDIT => 0, 1, 0],
		[USER_ACCOUNT_EDIT_BY_SUPER_USER => 0, 0, 1],
		[USER_ACCOUNT_DELETE => 0, 0, 0],
	    ),
	    [USER_ACCOUNT_DELETE => 'demo', 'su_demo'] => 1,
	    [USER_ACCOUNT_DELETE => 'demo', 'su_root'] => 0,
	],
    ],
]);
