# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SVNTunnel;
use strict;
use Bivio::Base 'Action.TunnelBase';
use MIME::Base64 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    host => Bivio::IO::Config->REQUIRED,
    scheme => 'https',
    user_password => Bivio::IO::Config->REQUIRED,
});

sub URI_NAME {
    return 'svn';
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new({
	request => $req,
	site_base => $_CFG->{scheme} . '://' . $_CFG->{host},
	host => $_CFG->{host},
	response_file => b_use('IO.File')->temp_file($req),
    });
    my($http_req) = $self->internal_proxy_request($self->req('uri'));
    $http_req->header(Authorization => 'Basic ' . MIME::Base64::encode(
	join(':', $self->internal_email, $_CFG->{user_password}), ''));
    $self->internal_set_reply($self->internal_send_http_request($http_req, 0));
    return 1;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
