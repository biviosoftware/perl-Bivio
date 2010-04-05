# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SiteAdminSubstituteUserForm;
use strict;
use Bivio::Base 'Model.AdmSubstituteUserForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub can_substitute_user {
    my($self, $user_id) = @_;
    my($req) = $self->req;
    return 0
	unless my $super_users = $req->cache_for_auth_user(
	    $req->get('auth_id'),
	    sub {
		return undef
		    if $req->is_substitute_user
		    || !b_use('UI.Facade')
		    ->get_from_source($req)
		    ->auth_realm_is_site_admin($req);
		return {@{$self
		    ->new_other('SiteAdminSuperUserList')
		    ->map_iterate(
			sub {shift->get('RealmUser.user_id') => 1},
		    )
		}};
	    },
	);
    return 0
	unless $super_users->{$req->get('auth_user_id')};
    return $super_users->{$user_id} ? 0 : 1;
}

1;
