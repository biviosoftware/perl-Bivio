# Copyright (c) 2004-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Forbidden;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::Ext::ApacheConstants;


sub execute {
    # DEPRECATED: use View.Error
    my($proto, $req) = @_;
    my($reply) = $req->get('reply');
    $reply->set_http_status(Bivio::Ext::ApacheConstants->FORBIDDEN)
        if $reply->can('set_http_status');
    $reply->set_output(\(<<'EOF'));
<!DOCTYPE html>
<html><head>
<title>403 Forbidden</title>
</head><body>
<h1>Forbidden</h1>
<p>You do not have permission to access this request on this server.</p>
</body></html>
EOF
    $reply->set_output_type('text/html');
    return 1;
}

1;
