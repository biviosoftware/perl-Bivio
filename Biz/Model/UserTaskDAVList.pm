# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserTaskDAVList;
use strict;
use Bivio::Base 'Model.DAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AT) = b_use('Agent.Task');
my($_MT) = b_use('MIME.Type');
my($_DT) = b_use('Type.DateTime');
my($_ATDL) = b_use('Model.AnyTaskDAVList');

sub REGEXP {
    return qr/^[A-Z][\w\s\.]+$/;
}

sub dav_propfind_children {
    my($self) = @_;
    my($req) = $self->get_request;
    my($q) = $self->get_query;
    my($prev) = $req->get('auth_realm');
    $req->set_realm($q->get('auth_id'));
    my($t) = $_AT->get_by_id($q->get('task_id'));
    my($res) = $t->map_each(
	sub {
	    my(undef, $k, $tid) = @_;
	    return $k =~ /^(\w+)_task$/ ? _fmt($self, lc($1), $tid) : ();
	},
    );
    $req->set_realm($prev);
    return $res;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        other_query_keys => ['task_id'],
	# Needed, but not used
	primary_key => ['RealmOwner.realm_id'],
	auth_id => ['RealmOwner.realm_id'],
    });
}

sub internal_load_rows {
    return shift->root_dav_row;
}

sub load_dav {
    my($self) = @_;
    my($req) = $self->get_request;
    my($this, $next) = $req->get('path_info') =~ m{^/([^/]+)(.*)};
    unless ($this) {
	$self->load_all({
	    path_info => '',
	    task_id => $req->get('task_id'),
	});
	return 1;
    }
    $this =~ s/[\s\.]/_/g;
    Bivio::Die->throw_quietly(MODEL_NOT_FOUND => {
	class => ref($self),
	entity => "${this}_task",
    }) unless my $t = $req->get('task')->unsafe_get_attr_as_id(lc("${this}_task"));
    $req->put(path_info => $next);
    return $t;
}

sub _fmt {
    my($self, $name, $task_id) = @_;
    my($req) = $self->get_request;
    my($t) = $_AT->get_by_id($task_id);
    # Not writable, just readable
    return unless $req->can_user_execute_task($task_id);
    my($ct) = $t->unsafe_get('require_dav') || grep(/_task$/, $t->get_keys) ? ()
      : ($name =~ s/_([a-z]{3,4})$/.$1/
	 && $_MT->unsafe_from_extension($name));
    $name = ucfirst($name);
    $name =~ s/_(\w?)/ \u$1/g;
    return {
	getlastmodified => $_DT->now,
	uri => $name,
	displayname => $name,
	$ct ? (getcontenttype => $ct, getcontentlength => _size($t, $req)) : (),
    }
}

sub _size {
    my($t, $req) = @_;
    my($prev_id, $prev_task, $prev_realm)
	= $req->get(qw(task_id task auth_realm));
    $req->put(task_id => $t->get('id'), task => $t);
    if ($t->unsafe_get('require_dav')
        || grep(($_->[0] || '') =~ /DAV/, @{$t->get('items')})) {
	$req->get('task')->execute_items($req);
    }
    else {
	$_ATDL->execute($req);
    }
    my($m) = $req->get('dav_model');
    my($o) = $m->can('dav_reply_get')
	? ($m->dav_reply_get, $req->get('reply')->unsafe_get_output)[1]
	: $m->dav_get;
    # Need to rollback, because may be a lock.  UserTaskDAVList doesn't hold
    # locks, because essentially a directory
    $t->rollback($req);
    $req->put(task_id => $prev_id, task => $prev_task);
    # OPTIMIZATION: avoid database problem
    $req->set_realm($prev_realm)
	unless $prev_realm->equals($req->get('auth_realm'));
    $req->reset_reply;
    return ref($o) eq 'SCALAR' ? length($$o)
	: b_die($t->get('id'), ': failed to return scalar: ', $o);
}

1;
