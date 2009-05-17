# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CLASS_TO_SINGLETON) = {};

sub CLASSLOADER_MAP_NAME {
    return 'Action';
}

sub delete_from_request {
    my($proto, $req) = @_;
    return $proto->delete_from_req($req);
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
    my($self) = @_;
    return ref($self) && $self->unsafe_get('req')
	|| shift->SUPER::get_request(@_);
}

sub put_on_request {
    my($self, $req, $durable) = @_;
    b_die($self, ': may not put singleton on request')
	if $self->get_instance == $self;
    return $self->put_on_req($req, $durable);
}

1;
