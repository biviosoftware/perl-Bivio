# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_GENERAL) = b_use('Auth.Realm')->get_general->get('id');
my($_PI) = b_use('Type.PrimaryId');
my($_SQL_READ_ONLY) = b_use('SQL.Connection')->is_read_only;
my($_D) = b_use('Bivio.Die');

sub acquire {
    my($self, $realm_id) = @_;
    $realm_id ||= $self->req('auth_id');
    if (my $other = $self->req->unsafe_get(ref($self))) {
	$other->throw_die(ALREADY_EXISTS => {
	    message => 'more than one lock on the request',
	});
	# DOES NOT RETURN
    }
    my($values) = {realm_id => $realm_id};
    _read_request_input($self);
    my($die) = $_D->catch(sub {$self->create($values)});
    if ($die) {
	if ($die->get('code')->equals_by_name('DB_CONSTRAINT')) {
	    my($a) = $die->unsafe_get('attrs');
	    $self->throw_die('DB_ERROR', $values)
		if ref($a) && ref($a->{type_error})
		    && $a->{type_error}->equals_by_name('EXISTS');
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
    return 0
	unless my $other = $self->unsafe_self_from_req($self->req);
    return $_PI->is_equal(
	$other->get('realm_id'),
	$realm_id || $self->req('auth_id'),
    );
}

sub is_general_acquired {
    my($self) = @_;
    return $self->is_acquired($_GENERAL);
}

sub release {
    my($self) = @_;
    my($req_lock) = $self->req->unsafe_get(ref($self));
    $self->throw_die('DIE', 'no locks on request')
	unless $req_lock;
    $self->throw_die(
	'DIE',
	{
	    message => 'too many locks on the same request',
	    request_lock => $req_lock,
	},
    ) unless $req_lock == $self;
    _trace($self) if $_TRACE;
    $self->delete_from_request;
    $self->throw_die('UPDATE_COLLISION')
	unless $self->delete || $_SQL_READ_ONLY;
    return;
}

sub _read_request_input {
    my($self) = @_;
    my($m) = $self->req->is_http_method('post') ? 'get_form' : 'get_content';
    $self->req->$m();
    return;
}

1;
