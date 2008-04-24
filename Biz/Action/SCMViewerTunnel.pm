# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SCMViewerTunnel;
use strict;
use Bivio::Base 'Action.TunnelBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    host => Bivio::IO::Config->REQUIRED,
    scheme => 'http',
#TODO: seems to have been configured on back-end, not the same as site_base
#      in Action.SFEETunnel (missing 'b' from app4)
    sf_base => Bivio::IO::Config->REQUIRED,
});

sub URI_NAME {
    return 'scm';
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new({
	request => $req,
	site_base => $_CFG->{scheme} . '://' . $_CFG->{host},
	host => $_CFG->{host},
	scheme => $_CFG->{scheme},
    });
    my($response) = $self->internal_send_http_request(
	$self->internal_proxy_request($self->req('path_info')), 0);
    my($res) = $self->internal_set_reply($response);
    $self->internal_add_reply_header(
	'Location', $self->internal_translate_location($response,
	    $self->use('Action.SFEETunnel')->URI_NAME));
    return 1 unless ($response->header('Content-Type') || '') =~
	m,^text/(html|css|javascript),i;

    my($realm_name) = $self->req(qw(auth_realm owner name));
    my($sf_uri_name) = $self->use('Action.SFEETunnel')->URI_NAME;
    my($uri_name) = $self->URI_NAME;
    my($host) = $self->internal_host_name;
    my($local_scheme) = $self->req->unsafe_get('is_secure') ? 'https' : 'http';
    $$res =~ s,$_CFG->{sf_base}/sf,$local_scheme://$host/$realm_name/$sf_uri_name/sf,g;
    $$res =~
	s,([='"])/(sf-help|sf-images)/,$1/$realm_name/$sf_uri_name/$2/,g;
    $$res =~
	s,([='"])/(integration)/,$1/$realm_name/$uri_name/$2/,g;
    return 1;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

1;
