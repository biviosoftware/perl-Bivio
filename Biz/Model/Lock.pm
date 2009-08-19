# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Lock;
use strict;
use Bivio::Base 'Biz.PropertyModel';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_GENERAL) = __PACKAGE__->use('Auth.Realm')->get_general;

sub acquire {
    my($self) = @_;
    if (my $other = $self->req->unsafe_get(ref($self))) {
	$other->throw_die(ALREADY_EXISTS => {
	    message => 'more than one lock on the request',
	});
	# DOES NOT RETURN
    }
    my($values) = {realm_id => $self->req('auth_id')};
    _read_request_input($self);
    my($die) = Bivio::Die->catch(sub {$self->create($values)});
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
    my($self) = @_;
    $self->req->with_realm(undef, sub {$self->acquire});
    return;
}

sub acquire_general_unless_exists {
    my($self) = @_;
    $self->req->with_realm(undef, sub {$self->acquire_unless_exists});
    return;
}

sub acquire_unless_exists {
    my($self) = @_;
    $self->acquire
	unless $self->is_acquired;
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
    my($self) = shift;
    return 0 unless my $other = $self->req->unsafe_get(ref($self));
    return $other->get('realm_id') eq $self->req('auth_realm')->id_from_any(@_)
	? 1 : 0;
}

sub is_general_acquired {
    my($self) = @_;
    return $self->is_acquired($_GENERAL);
}

sub release {
    my($self) = @_;
    my($req_lock) = $self->req->unsafe_get(ref($self));
    $self->throw_die('DIE', 'no locks on request') unless $req_lock;
    $self->throw_die('DIE', {message => 'too many locks on the same request',
	request_lock => $req_lock}) unless $req_lock == $self;
    _trace($self) if $_TRACE;
    $self->delete_from_request;
    $self->throw_die('UPDATE_COLLISION')
	    unless $self->delete() || Bivio::SQL::Connection->is_read_only;
    return;
}

sub _read_request_input {
    my($self) = @_;
    my($r) = $self->req->unsafe_get('r');
    return unless $r;
    my($m) = lc($r->method) eq 'post' ? 'get_form' : 'get_content';
    $self->req->$m();
    return;
}

1;
