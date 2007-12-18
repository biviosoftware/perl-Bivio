# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Error;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AC) = __PACKAGE__->use('Ext.ApacheConstants');

sub not_found {
    view_pre_execute(sub {
        my($req) = shift->get_request;
	$req->put(go_back => undef);
	$req->get('reply')->set_http_status($_AC->NOT_FOUND);
	return unless my $r = $req->unsafe_get('r');
	return unless $r = $r->header_in('Referer');
	$req->put(go_back => $r);
	return;
    });
    return shift->internal_body(DIV_not_found(Prose(<<'EOF')));
The page requested is not a functioning page on our site.
If(['go_back'],
   Link('Go back to the previous page, and try again.', ['go_back']),
   If(['auth_user'],
      Link('Go back to your home page.', 'MY_SITE'),
      Link('Go to the home page.', 'SITE_ROOT'),
));
EOF
}

1;
