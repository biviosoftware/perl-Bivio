# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Error;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub default {
    my($self, @extra) = @_;
    my($realm) = $self->internal_current_realm;
    return shift->internal_body(DIV_page_error(
	Join([
	    [sub {
                 my($req) = shift->req;
                 my($status) = $self->internal_error_status($req);
                 return $req->with_realm($realm, sub {
                     return vs_text_as_prose($req, 'page_error.'
                         . $status);
                 }) if $realm;
		 return vs_text_as_prose('page_error.' . $status);
	    }],
	    @extra ? @extra : (' ',
	    XLink(Cond(
		['->req', 'Action.Error', 'uri'] => 'page_error_referer',
		['auth_user_id'] => 'page_error_user',
		1 => 'page_error_visitor',
	    ))),
	]),
    ));
}

sub internal_current_realm {
    my($self) = @_;
    my($f, $c, $realm);
    ($f = $self->ureq('Model.ForbiddenForm'))
        && ($c = $f->unsafe_get_context)
        && ($realm = $c->unsafe_get_nested(qw(realm owner name)));
    return $realm;
}

sub internal_error_status {
    my(undef, $req) = @_;
    return $req->get_nested(qw(Action.Error status));
}

1;
