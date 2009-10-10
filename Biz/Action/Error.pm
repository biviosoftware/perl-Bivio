# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Error;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('IO.Config');
my($_SF) = b_use('Action.SiteForum');
my($_FC) = b_use('FacadeComponent.Constant');
my($_T) = b_use('FacadeComponent.Text');
my($_V) = b_use('UI.View');
my($_WV) = b_use('Action.WikiView');
my($_WARNINGS) = {};

sub execute {
    my($proto, $req) = @_;
    my($status) = lc($req->get('task_id')->get_name);
    $status =~ s/^default_error_redirect_?//s;
    $status ||= 'server_error';
    my($r);
    my($self) = $proto->new({
	status => $status,
	uri => ($r = $req->unsafe_get('r') and $r = $r->header_in('Referer')),
    })->put_on_request($req);
    my($reply) = $req->get('reply');
    $reply->delete_output;
    my($die) = Bivio::Die->catch_quietly(sub {_wiki($self, $req)});
    Bivio::IO::Alert->warn($status, ': wiki rendering error: ', $die)
        if $die && !$_WARNINGS->{$status}++;
    $_V->execute('Error->default', $req)
        if $die || ! $reply->unsafe_get_output;
    return $proto->SUPER::execute($req, uc($status));
}

sub _wiki {
    my($self, $req) = @_;
    return
	unless $_C->if_version(6);
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
	    $_V->execute('Wiki->site_view', $req);
	    return;
	},
    );
}

1;
