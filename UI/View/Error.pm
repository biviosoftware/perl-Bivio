# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Error;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub default {
    return shift->internal_body(DIV_page_error(
	Join([
	    [sub {
		 return vs_text_as_prose(
		    'page_error.' . shift->req(qw(Action.Error status)));
	    }],
	    XLink(Cond(
		['->req', 'Action.Error', 'uri'] => 'page_error_referer',
		['auth_user'] => 'page_error_user',
		1 => 'page_error_visitor',
	    )),
	]),
    ));
}

1;
