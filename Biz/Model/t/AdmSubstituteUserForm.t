# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
#
# Only works for petshop (needs demo and root) users
#
use strict;
use Bivio::Biz::Model::AdmSubstituteUserForm;
use Bivio::Biz::Action::UserLogout;
use Bivio::Test;
use Bivio::Test::Request;
# Most of the test work is implemented by UserLoginForm.t, so we
# just test the flow here.
my($_req) = Bivio::Test::Request->set_realm_and_user('general', 'root');
Bivio::Test->new->unit([
    'Bivio::Biz::Model::AdmSubstituteUserForm' => [
	execute => [
	    [$_req, {
		login => 'demo',
	    }] => sub {
		my($case, $return) = @_;
		return 0 unless $_req->is_substitute_user;
		push(@$return, $_req->get('auth_user')->get('name'));
		return [0, 'demo'];
	    },
	],
    ],
    'Bivio::Biz::Action::UserLogout' => [
	execute => [
	    [$_req] => [Bivio::Agent::TaskId->ADM_SUBSTITUTE_USER],
	    [$_req] => [0],
	],
    ],
]);
