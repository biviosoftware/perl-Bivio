# Copyright (c) 1999-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::IO::Trace;

our($_TRACE);
my($_GENERAL) = b_use('Auth.Realm')->get_general->get('id');
my($_PI) = b_use('Type.PrimaryId');
my($_SQL_READ_ONLY) = b_use('SQL.Connection')->is_read_only;
my($_D) = b_use('Bivio.Die');

sub acquire {
    my($self, $realm_id) = @_;
    $realm_id ||= $self->req('auth_id');
    $self->throw_die(
        'ALREADY_EXISTS',
        {
            message => 'duplicate lock: use acquire_unless_exists',
            entity => $realm_id,
        },
    ) if $self->is_acquired($realm_id);
    $self->throw_die('ALREADY_EXISTS', 'cannot reuse lock instance')
        if _map_txn_resources($self, sub {shift == $self ? 1 : ()});
    my($values) = {realm_id => $realm_id};
    _read_request_input($self);
    my($die) = $_D->catch(sub {$self->create($values)});
    if ($die) {
        if ($die->get('code')->equals_by_name('DB_CONSTRAINT')) {
            my($attrs) = $die->unsafe_get('attrs');
            $self->throw_die('DB_ERROR', $values)
                if ref($attrs) && ref($attrs->{type_error})
                    && $attrs->{type_error}->equals_by_name('EXISTS');
        }
        $die->throw_die;
        # DOES NOT RETURN
    }
    _trace($self) if $_TRACE;
    $self->req->push_txn_resource($self);
    return;
}

sub acquire_general {
    return shift->acquire($_GENERAL);
}

sub acquire_general_unless_exists {
    return shift->acquire_unless_exists($_GENERAL);
}

sub acquire_unless_exists {
    my($self, $realm_id) = @_;
    $self->acquire($realm_id)
        unless $self->is_acquired($realm_id);
    return;
}

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->acquire;
    return;
}

sub execute_auth_user {
    my($proto, $req) = @_;
    $proto->new($req)->acquire($req->get('auth_user_id'));
    return;
}

sub execute_general {
    my($proto, $req) = @_;
    $proto->new($req)->acquire_general;
    return;
}

sub execute_unless_acquired {
    my($proto, $req) = @_;
    $proto->new($req)->acquire_unless_exists;
    return;
}

sub handle_commit {
    my($self) = @_;
    $self->release;
    return;
}

sub handle_rollback {
    my($self) = @_;
    $self->delete_from_request;
    return;
}

sub internal_initialize {
    return {
        version => 1,
        table_name => 'lock_t',
        columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
        },
        auth_id => 'realm_id',
    };
}

sub is_acquired {
    my($self, $realm_id) = @_;
    $realm_id ||= $self->req('auth_id');
    return _map_txn_resources(
        $self,
        sub {_is_equal(shift, $realm_id) ? 1 : ()},
    ) ? 1 : 0;
}

sub is_general_acquired {
    my($self) = @_;
    return $self->is_acquired($_GENERAL);
}

sub release {
    my($self) = @_;
    _trace($self) if $_TRACE;
    $self->throw_die('DIE', 'lock is not loaded')
        unless $self->is_loaded;
    $self->req->delete_txn_resource($self);
    $self->throw_die('UPDATE_COLLISION')
        unless $self->delete || $_SQL_READ_ONLY;
    return;
}

sub release_all {
    my($self) = @_;
    _map_txn_resources(
        $self,
        sub {
            shift->release;
            return;
        },
    );
    return;
}

sub _is_equal {
    my($other, $realm_id) = @_;
    return $_PI->is_equal(
        $other->get('realm_id'),
        $realm_id || $other->req('auth_id'),
    );
}

sub _map_txn_resources {
    my($self, $op) = @_;
    return map(
        $self->is_blesser_of($_) ? $op->($_) : (),
        @{$self->req('txn_resources')},
    );
}

sub _read_request_input {
    my($self) = @_;
    my($m) = $self->req->is_http_method('post') ? 'get_form' : 'get_content';
    $self->req->$m();
    return;
}

1;
