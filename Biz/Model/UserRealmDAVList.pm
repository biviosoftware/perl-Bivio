# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserRealmDAVList;
use strict;
use base 'Bivio::Biz::Model::DAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RN) = Bivio::Biz::Model->get_instance('RealmOwner')
    ->get_field_type('name');

sub dav_propfind {
    my($self) = @_;
    return {
	%{shift->SUPER::dav_propfind(@_)},
	displayname => $self->get('RealmOwner.name'),
	uri => $self->get('RealmOwner.name'),
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	primary_key => ['RealmOwner.name'],
	want_select_distinct => 1,
	other => [
	    'RealmOwner.display_name',
	    ['RealmOwner.realm_id', 'RealmUser.realm_id'],
	    {
		name => 'RealmUser.role',
		in_select => 0,
	    },
	],
	other_query_keys => ['realm_type'],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    return $query->unsafe_get('this') ?  shift->SUPER::internal_load_rows(@_)
	: [{
	    'RealmOwner.display_name' => '/',
	    'RealmOwner.name' => '/',
	}];
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($req) = $self->get_request;
    $stmt->where(
	$stmt->EQ('RealmOwner.realm_type', [$query->get('realm_type')]),
	$stmt->EQ('RealmUser.user_id', [$req->get('auth_user_id')]),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub load_dav {
    my($self) = @_;
    my($req) = $self->get_request;
    my($this, $next) = $req->get('path_info') =~ m{^/([^/]+)(.*)};
    my($rt) = Bivio::Agent::Task->get_by_id(
	$req->get_nested(qw(task next)))->get('realm_type');
    unless ($this) {
	$self->load_all({path_info => '', realm_type => $rt});
	return 1;
    }
    Bivio::Die->throw_quietly(MODEL_NOT_FOUND => {
	class => ref($self),
	entity => $this,
    }) unless $this = ($_RN->from_literal($this))[0]
	    and $self->unsafe_load_this({
		this => $this,
		realm_type => $rt,
		path_info => $this,
	    });
    $req->set_realm($self->set_cursor_or_die(0)->get('RealmOwner.name'));
    $req->put(path_info => $next);
    return 'next';
}

1;
