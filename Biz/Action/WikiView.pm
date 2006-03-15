# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');
my($_WT) = Bivio::Type->get_instance('WikiText');

sub execute {
    my($proto, $req) = @_;
    unless ($req->unsafe_get('path_info')) {
	# To avoid name space issues, there always needs to be a path_info
	$req->put(path_info => 'StartPage');
	return $req->get('task_id');
    }
    my($p) = $_WN->absolute_path($req->get('path_info'));
    return $req->server_redirect({
	task_id => $req->get_nested(qw(task image_task)),
	query => undef,
	path_info => $p,
    }) if $p =~ $_WT->IMAGE_REGEX;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    $proto->new->put_on_request($req, 1)->put(
	name => $_WN->get_tail($p),
	exists => 0,
    )->put(
	html => $_WT->render_html(
	    $rf->load({path => $p})->get_content,
	),
	modified_date_time => $rf->get('modified_date_time'),
	author => $rf->new_other('Email')->unauth_load_or_die({
	    realm_id => $rf->get('user_id'),
	})->get('email'),
	exists => 1,
    );
    return 0;
}

1;
