# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
req()->set_realm_and_user('demo', 'demo');
Bivio::Biz::Model->new(req(), 'RealmFile')->delete_deep({
    path => Bivio::Type->get_instance('BlogFileName')->to_path,
});
commit();
Bivio::Type->get_instance('AccessMode')->execute_private(req());
1;
