# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
req()->set_realm_and_user('realmfile2', 'root');
model('RealmFile')->delete_all;
commit();
model('RealmFile')->init_realm;
commit();
1;
