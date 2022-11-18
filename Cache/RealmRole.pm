# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::RealmRole;
use strict;
use Bivio::Base 'Bivio.Cache';

my($_RR) = b_use('Model.RealmRole');
my($_RT) = b_use('Auth.RealmType');
b_use('IO.Config')->register(my $_CFG = {
    enable => 1,
});
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__)
    if $_CFG->{enable};

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_property_model_modification {
    my($proto, $model, $op, $query) = @_;
    return
        unless $model->simple_package_name eq 'RealmRole';
    my($req) = $model->req;
    return
        unless my $map = $proto->internal_retrieve($model->req);
    if ($op =~ /delete/) {
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

sub internal_compute_no_cache {
    my($self, $req, $realm_id, $role) = @_;
    my($rr) = $_RR->new($req);
    return {$realm_id => {$role->as_int => $rr->get('permission_set')}}
        if $rr->unauth_load({realm_id => $realm_id, role => $role});
    return undef;
}

sub permission_set_for_realm_role {
    return _not_enabled(@_)
        unless $_CFG->{enable};
    my($proto, $realm_id, $role, $req) = @_;
    my($res) = $proto->internal_retrieve($req, $realm_id, $role);
    return $res
        unless ref($res) eq 'HASH';
    return $res->{$realm_id}->{$role->as_int};
}

sub _not_enabled {
    my($proto, $realm_id, $role, $req) = @_;
    return undef
        unless my $res = $proto->internal_compute_no_cache($req, $realm_id, $role);
    return $res->{$realm_id}->{$role->as_int};
}

sub _update {
    my($model, $map) = @_;
    my($rid, $role, $ps) = $model->get(qw(realm_id role permission_set));
    $map->{$rid}->{$role->as_int} = $ps;
    return;
}

1;
