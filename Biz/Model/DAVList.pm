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

sub dav_propfind_children {
    my($self) = @_;
    my($q) = $self->get_query;
    return $self->new->map_iterate(
	sub {shift->dav_propfind},
	unauth_iterate_start => {
	    map(($_ => $q->get($_)), qw(auth_id path_info)),
	},
    );
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	other_query_keys => ['path_info'],
    });
}

sub execute {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    return 'next'
	unless $self->load_dav;
    $req->put(dav_model => $self);
    return 0;
}

1;
