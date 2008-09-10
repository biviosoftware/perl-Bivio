# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CLASS_TO_SINGLETON) = {};

sub delete_from_request {
    # (proto, Agent.Request) : undef
    # Deletes self from request
    my($proto, $req) = @_;
    $req->delete(
	'Action.' . $proto->simple_package_name,
	ref($proto) || $proto,
    );
    return;
}

sub execute {
    my($proto, $req, $class) = @_;
    die("abstract method")
	unless $class;
    return $proto->get_instance($class)->execute($req);
}

sub get_instance {
    my($proto, $class) = @_;
    $class = defined($class)
       ? b_use('Action', ref($class) ? ref($class) : $class)
       : ref($proto) ? ref($proto) : $proto;
    return $_CLASS_TO_SINGLETON->{$class} ||= $class->new->set_read_only;
}

sub get_request {
    return shift->get('req');
}

sub put_on_request {
    my($self, $req, $durable) = @_;
    b_die($self, ': must be instance')
	unless ref($self);
    b_die($self, ': may not put singleton on request')
	if $self->get_instance == $self;
    my($method) = $durable ? 'put_durable' : 'put';
    foreach my $key ('Action.' . $self->simple_package_name, ref($self)) {
	($req || $self->req)->$method($key => $self);
    }
    return $self;
}

1;
