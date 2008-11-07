# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MySite;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');
my($_RT) = b_use('Auth.RealmType');
my($_R) = b_use('Auth.Role');
my($_T) = b_use('FacadeComponent.Task');

sub execute {
    my(undef, $req) = @_;
    if (my $p = $req->unsafe_get('path_info')) {
	if (my $t = $_T->unsafe_get_from_uri($p, $_RT->USER, $req)) {
	    return {
		method => 'client_redirect',
		realm => $req->unsafe_get_nested(qw(auth_user name)),
		task_id => $t,
		path_info => undef,
		query => undef,
	    }
	}
    }
    my($realms) = $req->map_user_realms;
    foreach my $m (@{$_C->get_value('my_site_redirect_map', $req)}) {
	my($realm, $role, $uri) = @$m;
	$realm = $_RT->from_any($realm)
	    if $realm =~ /^[A-Z]/;
	$role = $_R->from_any($role)
	    if $role;
	next unless my $match = (grep(
	    (ref($realm) ? $_->{'RealmOwner.realm_type'} == $realm
		: $realm eq $_->{'RealmOwner.name'})
	    && (!$role || grep($_ == $role, @{$_->{roles}})),
	    @$realms,
	))[0];
	return {
	    $match->{'RealmOwner.realm_type'}->eq_general ? ()
		: (realm => $match->{'RealmOwner.name'}),
	    query => undef,
	    ref($uri) eq 'HASH' ? %$uri : (task_id => $uri),
	};
    }
    return {
	task_id => 'SITE_ROOT',
	query => undef,
    };
}

1;
