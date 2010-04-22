# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::RealmRole;
use strict;
use Bivio::Base 'Bivio.Cache';
use Storable ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RR) = b_use('Model.RealmRole');
my($_FILE);
my($_F) = b_use('IO.File');
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__);

sub handle_commit {
    unlink(_file());
    return;
}

sub permission_set_for_realm_role {
    my($self, $realm_id, $role, $req) = @_;
    return (
	_map($req)->{$realm_id}
	|| return undef
     )->{$role->as_int};
}

sub handle_property_model_modification {
    my($self, $model, $op, $query) = @_;
    return
	unless $model->simple_package_name eq 'RealmRole';
    my($req) = $model->req;
    my($map) = _map($model->req);
    if ($op eq 'delete') {
	b_die($query, 'must supply a realm_id to delete')
	    unless $query->{realm_id};
	if ($query->{role}) {
	    delete($map->{$query->{realm_id}}->{$query->{role}->as_int});
	}
	else {
	    delete($map->{$query->{realm_id}});
	}
    }
    else {
	_update($model, $map);
    }
    $req->push_txn_resource(__PACKAGE__);
    return;
}

sub handle_rollback {
    my(undef, $req) = @_;
    $req->delete(__PACKAGE__);
    return;
}

sub _compute {
    my($req) = @_;
    my($map) = {};
    $_RR->new($req)->set_ephemeral->do_iterate(
	sub {
	    _update(shift, $map);
	    return 1;
	},
	'unauth_iterate_start',
    );
    $_F->mkdir_parent_only(_file(), 0750);
    Storable::lock_store($map, $_FILE);
    return $map;
}

sub _file {
    return $_FILE ||= b_use('Biz.File')->absolute_path('Cache/RealmRole.storable');
}

sub _map {
    my($req) = @_;
    return $req->get_if_exists_else_put(
	__PACKAGE__,
	sub {_read($req) || _compute($req)},
    );
}

sub _read {
    return -r _file() && Storable::lock_retrieve($_FILE);
}

sub _update {
    my($model, $map) = @_;
    my($rid, $role, $ps) = $model->get(qw(realm_id role permission_set));
    $map->{$rid}->{$role->as_int} = $ps;
    return;
}

1;
