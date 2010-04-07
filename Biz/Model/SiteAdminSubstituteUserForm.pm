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
	unless my $users = $req->cache_for_auth_user(
	    $req->get('auth_id'),
	    sub {
		return undef
		    if $req->is_substitute_user
		    || !b_use('UI.Facade')
		    ->get_from_source($req)
		    ->auth_realm_is_site_admin($req);
		my($res) = {@{$self->new_other('GroupUserList')
		    ->map_iterate(
		        sub {shift->get('RealmUser.user_id') => 1},
		)}};
		$self->new_other('AdmSuperUserList')
		    ->do_iterate(sub {
		        delete($res->{shift->get('RealmUser.user_id')});
			return 1;
		    });
		return $res;
	    },
	);
    return $users->{$user_id} || 0;
}

1;
