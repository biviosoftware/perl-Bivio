# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Error;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SF) = b_use('Action.SiteForum');
my($_T) = b_use('FacadeComponent.Text');
my($_V) = b_use('UI.View');
my($_WV) = b_use('Action.WikiView');

sub execute {
    my($proto, $req) = @_;
    my($status) = lc($req->get('task_id')->get_name);
    $status =~ s/^default_error_redirect_?//s;
    $status ||= 'server_error';
    my($r);
    $proto->new({
	status => $status,
	uri => ($r = $req->unsafe_get('r') and $r = $r->header_in('Referer')),
    })->put_on_request($req);
    my($die) = Bivio::Die->catch(sub {
        $proto->execute_wiki($req);
    });
    $_V->execute('Error->default', $req)
        if $die || ! $req->get('reply')->unsafe_get_output;
    return $proto->SUPER::execute($req, uc($status));
}

sub execute_wiki {
    my($proto, $req) = @_;
    return 0
        unless $req->get('task_id')->is_component_included('wiki');
    $_SF->execute($req);
    $req->put(path_info => $_T->get_value(
        'ErrorWiki.file_path', $req->get_nested(qw(Action.Error status))));
    $_WV->execute_prepare_html($req);
    $_V->execute('Wiki->site_view', $req);
    return 0;
}

1;
