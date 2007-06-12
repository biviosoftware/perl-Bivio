# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::DAVList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dav_is_read_only {
    return 1;
}

sub as_string {
    my($self) = @_;
    if (my $q = $self->get_query) {
	my($r, $p) = $q->unsafe_get(qw(auth_id path_info));
	return ref($self) . "[$r,$p]"
	    if $r && $p;
    }
    return $self->SUPER::as_string;
}

sub dav_exists {
    return shift->get_result_set_size > 0 ? 1 : 0;
}

sub dav_propfind {
    my($self) = @_;
    return {
	getlastmodified => $self->unsafe_get('getlastmodified')
	    || Bivio::Type::DateTime->now,
	map(($_ => $self->unsafe_get($_)), qw(uri displayname)),
    };
}

sub dav_propfind_children {
    my($self) = @_;
    my($q) = $self->get_query;
    return $self->new->map_iterate(
	sub {shift->dav_propfind},
	unauth_iterate_start => {
	    map(($_ => $q->unsafe_get($_)),
		'auth_id',
		@{$self->internal_get_sql_support->get('other_query_keys')},
	    ),
	},
    );
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($res) = $self->load_dav;
    $req->put(dav_model => $self);
    return $res;
}

sub get_auth_id {
    my($self) = @_;
    return (
	$self->get_query
        || $self->get_request->is_test && $self->get_request
    )->get('auth_id');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	other => [
	    {
		name => 'displayname',
		type => 'Line',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	    {
		name => 'getlastmodified',
		type => 'DateTime',
		constraint => 'NONE',
		in_list => 1,
	    },
	    {
		name => 'uri',
		type => 'FilePath',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
	other_query_keys => ['path_info'],
    });
}

sub root_dav_row {
    my($self) = @_;
    return [{
	displayname => '/',
	uri => '',
    }];
}

1;
