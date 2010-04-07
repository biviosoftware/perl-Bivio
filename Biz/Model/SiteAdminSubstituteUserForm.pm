# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SiteAdminSubstituteUserForm;
use strict;
use Bivio::Base 'Model.AdmSubstituteUserForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');

sub can_substitute_user {
    my($self, $user_id) = @_;
    my($req) = $self->req;
    return 0
	unless my $users = $req->cache_for_auth_user(
	    [],
	    sub {
		return undef
		    if $req->is_substitute_user;
		my($auid) = $req->get('auth_user_id');
		my($found);
		my($res) = {@{$self->new_other('GroupUserList')
		    ->map_iterate(
		        sub {
			    my($uid, $role) = shift->get(qw(RealmUser.user_id RealmUser.role));
			    $found++
				if $uid eq $auid && $role->eq_administrator;
			    return ($uid => 1);
			},
			'unauth_iterate_start',
			{
			    auth_id =>
			    $_C->get_value('site_admin_realm_id', $req),
			},
		       ),
		}};
		return undef
		    unless $found || $req->is_super_user;
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
