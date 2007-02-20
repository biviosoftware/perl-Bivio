# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SetRealm;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_from_uri {
    my($self, $req) = @_;
    my($realm, $pi) = $req->get('uri') =~ qr{^/(\w+)(/.*)?$};
    $req->set_realm($realm);
    $req->put_durable(path_info => $pi);
    return;
}

1;
