# Copyright (c) 2002 bivio Software, Inc.  All rights reserved.
# $Id$
use Bivio::Test::Request;
Bivio::IO::Config->introduce_values({
    'Bivio::IO::ClassLoader' => {
	maps => {
	    'Action' => ['Bivio::Biz::t::Action'],
	},
    },
});
Bivio::Test->new({
    class_name => 'Bivio::Biz::Action',
    create_object => sub {
	my($case, $params) = @_;
	return $params->[0] =~ /::/ ? $params->[0]
	    : Bivio::Biz::Action->get_instance(@$params);
    },
    compute_params => sub {
	return [Bivio::Test::Request->get_instance];
    },
})->unit([
    T1 => [
	execute => 0,
	execute_dev => Bivio::DieCode->DIE,
    ],
    Bivio::Biz::t::Action::T1 => [
	execute_dev => Bivio::DieCode->DIE,
    ],
]);
