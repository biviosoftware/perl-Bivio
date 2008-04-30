# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Error;
use strict;
use Bivio::Base 'Action.EmptyReply';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_V) = __PACKAGE__->use('UI.View');

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
    $_V->execute('Error->default', $req);
    return $proto->SUPER::execute($req, uc($status));
}

1;
