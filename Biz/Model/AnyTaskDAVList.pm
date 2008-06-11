# Copyright (c) 2005-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AnyTaskDAVList;
use strict;
use Bivio::Base 'Model.UserTaskDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AT) = b_use('Agent.Task');
my($_RF) = b_use('Model.RealmFile');

sub dav_propfind {
    my($self) = @_;
    return {
	%{shift->SUPER::dav_propfind(@_)},
	getcontenttype => $_RF->get_content_type_for_path(
	    $self->get_query->get('path_info')),
    };
}

sub dav_reply_get {
    my($self) = @_;
    my($req) = $self->get_request;
    my($q) = $self->get_query;
    $req->put(
	task_id => $q->get('task_id'),
	task => my $t = $_AT->get_by_id($q->get('task_id')),
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
