# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MySite;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('UI.Constant');
my($_RT) = __PACKAGE__->use('Auth.RealmType');
my($_R) = __PACKAGE__->use('Auth.Role');

sub execute {
    my(undef, $req) = @_;
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
