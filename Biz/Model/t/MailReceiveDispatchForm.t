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
    my($recipient, $from, $reply_to) = @$params;
    return [$_req,  {
	recipient => $recipient,
	client_addr => '1.2.3.4',
	message => {
	    name => '',
	    content => Bivio::IO::Ref->to_scalar_ref(<<"EOF"),
From: $from\@bivio.biz
@{[$reply_to ? "Reply-To: $reply_to\@bivio.biz" : '']}

EOF
	},
    }];
};
my($_check_return) = sub {
    my($case, undef, $expect) = @_;
    $case->actual_return([
	$_req->get('auth_user')	&& $_req->get('auth_user')->get('name'),
	$_req->get('auth_realm')->unsafe_get('owner_name'),
    ]);
    return $expect;
};
Bivio::Test->new({
    check_return => $_check_return,
    compute_params => $_compute_params,
})->unit([
    'Bivio::Biz::Model::MailReceiveDispatchForm' => [
	execute => [
	    ['demo-ignore', 'demo'] => ['demo', 'demo'],
	    ['demo-ignore', 'not_a_user'] => [undef, 'demo'],
	    ['not_a_user-ignore', 'demo'] => Bivio::DieCode->NOT_FOUND,
	    ['demo', 'demo'] => Bivio::DieCode->NOT_FOUND,
	],
    ],
]);
