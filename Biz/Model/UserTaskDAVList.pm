# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserTaskDAVList;
use strict;
use base 'Bivio::Biz::Model::DAVList';
use Bivio::MIME::Type;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGEXP {
    return qr/^[A-Z][\w\s\.]+$/;
}

sub dav_propfind_children {
    my($self) = @_;
    my($req) = $self->get_request;
    my($q) = $self->get_query;
    my($prev) = $req->get('auth_realm');
    $req->set_realm($q->get('auth_id'));
    my($t) = Bivio::Agent::Task->get_by_id($q->get('task_id'));
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
    }) unless my $t = $req->get('task')->unsafe_get(lc("${this}_task"));
    $req->put(path_info => $next);
    return $t;
}

sub _fmt {
    my($self, $name, $task_id) = @_;
    my($req) = $self->get_request;
    my($t) = Bivio::Agent::Task->get_by_id($task_id);
    return unless $req->can_user_execute_task($task_id);
    my($ct) = $t->unsafe_get('require_dav') || grep(/_task$/, $t->get_keys) ? ()
      : ($name =~ s/_([a-z]{3,4})$/.$1/
	 && Bivio::MIME::Type->unsafe_from_extension($name));
    $name = ucfirst($name);
    $name =~ s/_(\w?)/ \u$1/g;
    return {
	getlastmodified => Bivio::Type::DateTime->now,
	uri => $name,
	displayname => $name,
	$ct ? (getcontenttype => $ct) : (),
    }
}

1;
