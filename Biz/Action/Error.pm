# Copyright (c) 2008-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Error;
use strict;
use Bivio::Base 'Action.EmptyReply';

my($_C) = b_use('IO.Config');
my($_SF) = b_use('Action.SiteForum');
my($_FC) = b_use('FacadeComponent.Constant');
my($_T) = b_use('FacadeComponent.Text');
my($_V) = b_use('UI.View');
my($_WV) = b_use('Action.WikiView');
my($_JR) = b_use('Action.JSONReply');
my($_WARNINGS) = {};

sub execute {
    my($proto, $req) = @_;
    return $_JR->execute_check_req_is_json(
	$req,
	sub {
	    my($status) = $req->get('task_id')->get_name;
	    $status = $1 || 'SERVER_ERROR'
		if $status =~ /^DEFAULT_ERROR_REDIRECT_?(.*)/s;
	    return $proto->SUPER::execute(
		$req,
		$proto->internal_render_content($req, $status) || $status,
	    );
	},
    );
}

sub internal_render_content {
    my($proto, $req, $status) = @_;
    my($r) = $req->unsafe_get('r');
    my($self) = $proto->new({
	status => $status,
	uri => $r && $r->header_in('Referer') || undef,
    })->put_on_req($req);
    my($reply) = $req->get('reply');
    $reply->delete_output;
    return
	unless $_C->if_version(6)
	&& $_FC->get_value('ActionError_want_wiki_view', $req);
    my($die) = Bivio::Die->catch_quietly(sub {_wiki($self, $req)});
    b_warn($status, ': wiki rendering error: ', $die)
        if $die && !$_WARNINGS->{$status}++;
    $_V->execute(
	$_FC->get_value('ActionError_default_view', $req),
	$req,
    ) if $die || !$reply->unsafe_get_output;
    return;
}

sub _wiki {
    my($self, $req) = @_;
    return $req->with_realm(
	$_FC->get_value('site_realm_id', $req),
	sub {
	    my($wn);
	    foreach my $try ($self->get('status'), 'default') {
		last
		    if $wn = $_T->get_from_source($req)
		    ->unsafe_get_value('ActionError.wiki_name', $try);
	    }
	    return
		unless $wn;
	    $req->put(path_info => $wn);
	    $_WV->execute_prepare_html($req);
	    $req->set_task('FORUM_WIKI_VIEW');
	    $_V->execute('Wiki->site_view', $req);
	    return;
	},
    );
}

1;
