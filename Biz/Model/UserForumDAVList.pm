# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserForumDAVList;
use strict;
use base 'Bivio::Biz::Model::UserRealmDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TASK_REGEXP) = Bivio::Biz::Model->get_instance('UserTaskDAVList')->REGEXP;

sub dav_propfind_children {
    my($self) = @_;
    my($q) = $self->get_query;
    return [
	@{shift->SUPER::dav_propfind_children(@_)},
	$q->unsafe_get('this') ? ()
	    : @{$self->new_other('UserTaskDAVList')
	       ->unauth_load_all({
		   map(($_ => $q->get($_)), qw(task_id path_info auth_id)),
	       })->dav_propfind_children},
    ];
}

sub execute {
    my(undef, $req) = @_;
    my($this) = $req->get('path_info') =~ m{^/([^/]+)};
    return ($this || '') =~ $_TASK_REGEXP
	? shift->get_instance('UserTaskDAVList')->execute(@_)
	: shift->SUPER::execute(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [{
	    name => 'RealmOwner.name',
	    type => 'ForumName',
	}],
        auth_id => ['Forum.parent_realm_id'],
        other => [
	    [qw(RealmOwner.realm_id Forum.forum_id)],
	],
	other_query_keys => ['task_id'],
    });
}

sub load_all {
    my($self, $query) = @_;
    $query->{task_id} = $self->get_request->get('task_id');
    return shift->SUPER::load_all(@_);
}

1;
