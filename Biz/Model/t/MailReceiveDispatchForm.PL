# Copyright (c) 2015 bivio Software, Inc.  All Rights Reserved.
# $Id$

{
    method => 'process',
    compute_params => sub {
        my($case, $params) = @_;
        req()->set_realm(undef);
        req()->set_user(undef);
        my($from, $recipient, $header) = @$params;
        $header ||= '';
        $recipient = $recipient . '@bivio.biz'
            unless $recipient =~ /\@/;
        $from = email($from)
            unless $from =~ /\@/;
        return [req(),  {
            recipient => $recipient,
            client_addr => '1.2.3.4',
            message => {
                name => '',
                content => \(qq{From: $from$header\nMessage-ID: <$from>\n\n}),
            },
        }];
    },
    check_return => sub {
        my($case, $actual, $expect) = @_;
        my($subscription) = model('UserRealmSubscription');
        $subscription->unsafe_load({
            user_id => req('auth_user_id'),
        }) if req('auth_id') && req('auth_user_id');
        my($is_subscribed) = $subscription->is_loaded
            ? $subscription->get('is_subscribed')
                : 0;
        $case->actual_return([
            ureq(qw(auth_user name)),
            ureq(qw(auth_realm owner_name)),
            $actual->[0]->{task_id},
            $case->get('object')->get('recipient'),
            $is_subscribed,
        ]);
        return [
            @$expect[0,1],
            $expect->[2] || 'MAIL_RECEIVE_IGNORE',
            $expect->[3] || $case->get('object')->get('recipient'),
            defined($expect->[4]) ? $expect->[4] : $is_subscribed,
        ];
    },
};
