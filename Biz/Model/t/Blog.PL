# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
req()->initialize_fully->set_realm_and_user('demo', 'demo');
foreach my $x (0, 1) {
    Bivio::Biz::Model->new(req(), 'RealmFile')->unauth_delete_deep({
	path => Bivio::Type->get_instance('BlogFileName')
	    ->to_absolute(undef, $x),
	realm_id => req('auth_id'),
    });
}
commit();
Bivio::Type->get_instance('AccessMode')->execute_private(req());
1;
