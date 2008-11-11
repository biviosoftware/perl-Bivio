# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmDAVList;
use strict;
use Bivio::Base 'Model.DAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');

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
    my($rt) = $_RT->from_any($query->get('realm_type'));
    $stmt->where($stmt->IN('RealmOwner.realm_type', $rt->self_or_any_group));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub load_dav {
    my($self) = @_;
    my($req) = $self->get_request;
    my($this, $next) = $req->get('path_info') =~ m{^/([^/]+)(.*)};
    my($rt) = Bivio::Agent::Task->get_by_id(
	$req->get('task')->get_attr_as_id('next')
    )->get('realm_type');
    unless ($this) {
	$self->load_all({path_info => '', realm_type => $rt});
	return 1;
    }
    Bivio::Die->throw_quietly(MODEL_NOT_FOUND => {
	class => ref($self),
	entity => [$rt, $this],
    }) unless $this
	= ($self->get_field_type('RealmOwner.name')->from_literal($this))[0]
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
