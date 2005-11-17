# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AnyTaskDAVList;
use strict;
use base 'Bivio::Biz::Model::UserTaskDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dav_propfind {
    my($self) = @_;
    return {
	%{shift->SUPER::dav_propfind(@_)},
	getcontenttype => Bivio::MIME::Type->from_extension(
	    $self->get_query->get('path_info')),
    };
}

sub dav_reply_get {
    my($self) = @_;
    my($req) = $self->get_request;
    my($q) = $self->get_query;
    $req->put(
	task_id => $q->get('task_id'),
	task => my $t = Bivio::Agent::Task->get_by_id($q->get('task_id')),
    );
    $req->set_realm($q->get('auth_id'));
    $t->execute_items($req);
    return 1;
}

sub load_dav {
    my($self) = @_;
    my($req) = $self->get_request;
    $self->load_all({
	path_info => $req->get('path_info'),
	task_id => $req->get('task_id'),
    });
    return 1;
}

sub internal_load_rows {
    return shift->root_dav_row;
}

1;
