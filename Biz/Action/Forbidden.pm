# Copyright (c) 2004-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Forbidden;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::Ext::ApacheConstants;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    # DEPRECATED: use View.Error
    my($proto, $req) = @_;
    my($reply) = $req->get('reply');
    $reply->set_http_status(Bivio::Ext::ApacheConstants->FORBIDDEN)
	if $reply->can('set_http_status');
    $reply->set_output(\(<<'EOF'));
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>403 Forbidden</TITLE>
</HEAD><BODY>
<H1>Forbidden</H1>
<P>You do not have permission to access this request on this server.</P>
</BODY></HTML>
EOF
    $reply->set_output_type('text/html');
    return 1;
}

1;
