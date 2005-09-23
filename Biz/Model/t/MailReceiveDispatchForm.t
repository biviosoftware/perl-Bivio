# $Id$
# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
#
# Only works for petshop (needs demo) users
#
use strict;
use Bivio::Biz::Model::MailReceiveDispatchForm;
use Bivio::Test::Request;
my($_req) = Bivio::Test::Request->get_instance->setup_facade;
my($_compute_params) = sub {
    my($case, $params) = @_;
    my($from, $recipient) = @$params;
    return [$_req,  {
	recipient => $recipient,
	client_addr => '1.2.3.4',
	message => {
	    name => '',
	    content => Bivio::IO::Ref->to_scalar_ref(<<"EOF"),
From: @{[$from =~ /\@/ ? $from : "$from\@bivio.biz"]}

EOF
	},
    }];
};
my($_check_return) = sub {
    my($case, undef, $expect) = @_;
    $case->actual_return([
	$_req->get('auth_user')	&& $_req->get('auth_user')->get('name'),
	$_req->get('auth_realm')->unsafe_get('owner_name'),
	$_req->get('task_id'),
    ]);
    return [@$expect[0..1], $expect->[2] || Bivio::Agent::TaskId->MAIL_RECEIVE_IGNORE];
};
Bivio::Test->new({
    check_return => $_check_return,
    compute_params => $_compute_params,
})->unit([
    'Bivio::Biz::Model::MailReceiveDispatchForm' => [
	execute => [
	    # [From:, To:] => [auth_user, auth_realm]
	    ['demo', 'demo-ignore'] => ['demo', 'demo'],
	    ['demo', 'ignore.demo'] => ['demo', 'demo'],
	    ['Bob <demo@bivio.biz>', 'ignore.demo'] => ['demo', 'demo'],
	    ['not_a_user', 'demo-ignore'] => [undef, 'demo'],
	    ['demo', 'not_a_user-ignore'] => Bivio::DieCode->MODEL_NOT_FOUND,
	    ['demo', 'demo'] => [demo => demo => Bivio::Agent::TaskId->MAIL_RECEIVE],
	    ['demo', 'demo-ignore+antything'] => ['demo', 'demo'],
	    # Should not see "unknown facade uri"
	    ['demo', 'demo-ignore+antything@petshop.bivio.biz'] => ['demo', 'demo'],
	],
    ],
]);
