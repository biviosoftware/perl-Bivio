# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Support;
use strict;
use Bivio::Base 'Delegate.SimpleAuthSupport';


sub extra_auth_realm_bunit {
    my($proto, $realm, $task, $req) = @_;
    return 1
	unless defined(my $x = $req->unsafe_get('Realm.bunit'));
    $req->put('Realm.bunit' => [$realm->unsafe_get('owner_name'), $task->get('id')->get_name]);
    return $x;
}

1;
