# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::RealmRole;
use strict;
use Bivio::Base 'Bivio.Cache';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RR) = b_use('Model.RealmRole');
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__);

sub handle_property_model_modification {
    my($proto, $model, $op, $query) = @_;
    return
	unless $model->simple_package_name eq 'RealmRole';
    my($req) = $model->req;
    my($map) = $proto->internal_retrieve($model->req);
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

sub internal_compute {
    my($self, $req) = @_;
    my($map) = {};
    $_RR->new($req)->set_ephemeral->do_iterate(
	sub {
	    _update(shift, $map);
	    return 1;
	},
	'unauth_iterate_start',
    );
    return $map;
}

sub permission_set_for_realm_role {
    my($proto, $realm_id, $role, $req) = @_;
    return (
	$proto->internal_retrieve($req)->{$realm_id}
	|| return undef
     )->{$role->as_int};
}

sub _update {
    my($model, $map) = @_;
    my($rid, $role, $ps) = $model->get(qw(realm_id role permission_set));
    $map->{$rid}->{$role->as_int} = $ps;
    return;
}

1;
