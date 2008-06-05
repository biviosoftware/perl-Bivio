# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::SFEETunnel;
use strict;
use Bivio::Base 'Action.TunnelBase';
use HTTP::Request::Common ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    admin_password => Bivio::IO::Config->REQUIRED,
    admin_user => 'admin',
    host => Bivio::IO::Config->REQUIRED,
    scheme => 'http',
    user_password => Bivio::IO::Config->REQUIRED,
});

sub URI_NAME {
    return 'tx';
}

sub execute {
    my($proto, $req) = @_;
    return _execute(_assert_tunnel_enabled($proto, $req));
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub update_user_info {
    my($proto, $req, $old_username) = @_;
    my($self) = _assert_tunnel_enabled($proto, $req);
    $old_username ||= $self->internal_username;
    _login($self, $_CFG->{admin_user}, $_CFG->{admin_password});
    my($response) = $self->internal_send_http_request(
	HTTP::Request::Common::GET($self->get('site_base')
	    . '/sf/global/do/editUser/' . $old_username), 1);
    my($version) = $response->content =~ m,name="version" value="(\d+)",;
    # sf returns an empty form instead of not found
    return 0 unless $version;
    $self->internal_send_http_request(HTTP::Request::Common::POST(
 	$self->get('site_base') . '/sf/global/do/editUser/'
	. $self->internal_username, [
	    sfsubmit => 'submit',
	    username => $self->internal_username,
	    version => $version,
	    fullName => $self->req(qw(auth_user display_name)),
	    email => $self->internal_email,
	    userDatePattern => 'yyyy-MM-dd',
	    userTimePattern => 'HH:mm',
	    status => 'Active',
	]), 1);
    return 1;
}

sub _assert_tunnel_enabled {
    my($proto, $req) = @_;
    $proto->use('Model.RowTag')->new($req)->load({
	primary_id => $req->get('auth_id'),
	key => $proto->use('Type.RowTagKey')->FORUM_SFEE_TUNNEL,
	value => 1,
    });
    return $proto->new->put(
	request => $req,
	site_base => $_CFG->{scheme} . '://' . $_CFG->{host},
	host => $_CFG->{host},
	scheme => $_CFG->{scheme},
    );
}

sub _create_and_login {
    my($self) = @_;
    $self->internal_send_http_request(HTTP::Request::Common::POST(
	$self->get('site_base') . '/sf/sfmain/do/createUser', [
	    sfsubmit => 'submit',
	    username => $self->internal_username,
	    password => $_CFG->{user_password},
	    confirmPassword => $_CFG->{user_password},
	    fullName => $self->req(qw(auth_user display_name)),
	    email => $self->internal_email,
	]), 1);
    $self->internal_send_http_request(HTTP::Request::Common::GET(
	$self->get('site_base') . '/sf/sfmain/do/logout'), 1);
    return _login($self);
}

sub _edit_or_create_and_login {
    my($self) = @_;
    _login($self, $_CFG->{admin_user}, $_CFG->{admin_password});
    my($response) = $self->internal_send_http_request(
	HTTP::Request::Common::GET($self->get('site_base')
	    . '/sf/global/do/editUser/' . $self->internal_username), 1);
    my($version) = $response->content =~ m,name="version" value="(\d+)",;
    # sf returns an empty form instead of not found
    return _create_and_login($self) unless $version;
    $self->internal_send_http_request(HTTP::Request::Common::POST(
 	$self->get('site_base') . '/sf/global/do/editUser/'
	. $self->internal_username, [
	    sfsubmit => 'submit',
	    username => $self->internal_username,
	    password => $_CFG->{user_password},
	    confirmPassword => $_CFG->{user_password},
	    version => $version,
	    fullName => $self->req(qw(auth_user display_name)),
	    email => $self->internal_email,
	    userDatePattern => 'yyyy-MM-dd',
	    userTimePattern => 'HH:mm',
	    status => 'Active',
	]), 1);
    return _login($self);
}

sub _execute {
    my($self) = @_;
    my($response) = $self->internal_send_http_request(
	$self->internal_proxy_request($self->req('path_info')), 1);
    return {
	task_id => 'FORUM_WIKI_VIEW',
	path_info => '',
	query => '',
    } if ($self->req('path_info') || '') =~ m,^/sf/sfmain/do/logout,;
    my($res) = $self->internal_set_reply($response);
    $self->internal_add_reply_header(
	'Location', $self->internal_translate_location($response,
	    $self->use('Action.SCMViewerTunnel')->URI_NAME));
    return 1 unless ($response->header('Content-Type') || '') =~
	m,^text/(html|css|javascript),i;
    my($realm_name) = $self->req(qw(auth_realm owner name));
    my($uri_name) = $self->URI_NAME;
    $$res =~
	s,([='"])/(css|sf|sf-help|sf-images)/,$1/$realm_name/$uri_name/$2/,g;
    _fixup_svn_checkout_uri($self, $res);
    return 1 unless $response->header('Content-Type') =~ m,^text/html,i
	&& $$res =~ m,action="[^"]*/sf/sfmain/do/login\W,;
    Bivio::Die->die('login still present: ', $response)
	if $self->get_if_defined_else_put('login', 0) > 2;
    $self->put(login => $self->get('login') + 1);
    $self->req('reply')->delete('output');
    return $self->get('login') == 1
	? _login($self)
	: _edit_or_create_and_login($self);
}

sub _fixup_svn_checkout_uri {
    my($self, $res) = @_;
    my($username) = $self->internal_username;
    my($host) = $self->internal_host_name;
    $$res =~ s,(svn checkout --username $username) http(s)?\://[^/]+/,$1 https://$host/,g;
    return;
}

sub _login {
    my($self, $username, $password) = @_;
    $self->internal_send_http_request(HTTP::Request::Common::POST(
	$self->get('site_base') . '/sf/sfmain/do/login', [
	    sfsubmit => 'submit',
	    username => $username || $self->internal_username,
	    password => $password || $_CFG->{user_password},
	]), 1);
    return $username ? () : _execute($self);
}

1;
