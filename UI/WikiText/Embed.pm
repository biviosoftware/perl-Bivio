# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::WikiText::Embed;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->use('Type.WikiText')->register_tag('ins-page', __PACKAGE__);
__PACKAGE__->use('Type.WikiText')->register_tag('b-embed', __PACKAGE__);

sub render_html {
    my($proto, $args) = @_;
    Bivio::Die->die($args->{attrs}, ': does not accept attributes')
        if %{$args->{attrs}};
    my($uri) = $args->{value};
    return Bivio::Die->die('invalid URI, must begin with a /')
	unless $uri =~ s{^/+}{/};
    $uri = '/'
	. Bivio::Biz::Model->new($args->{req}, 'RealmOwner')
	    ->unauth_load_or_die({realm_id => $args->{realm_id}})
	    ->get('name')
	. $uri
        if $uri =~ s{^/my(?=/)}{}s
	&& !Bivio::Auth::Realm->is_default_id($args->{realm_id});
    return ${$proto->use('Bivio::Agent::Embed::Dispatcher')
	->call_task($args->{req}, $args->{req}->format_uri({
	    uri => $uri,
	    no_context => 1,
	    query => undef,
	    path_info => undef,
	}))};
}

1;
