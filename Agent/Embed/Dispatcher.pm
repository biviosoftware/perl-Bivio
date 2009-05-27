# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::Embed::Dispatcher;
use strict;
use Bivio::Base 'Agent.Dispatcher';
use Bivio::Agent::Embed::Request;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_SELF) = __PACKAGE__->initialize;

sub call_task {
    shift;
    my($req) = shift;
    $req->internal_clear_current;
    my($die) = $_SELF->process_request($req, @_);
    $req->internal_set_current;
    $die->throw
	if $die;
    return (
	$req->get('Bivio::Agent::Embed::Reply'),
	$req->delete('Bivio::Agent::Embed::Reply'),
    )[0];
}

sub create_request {
    shift;
    return Bivio::Agent::Embed::Request->new(@_);
}

sub initialize {
    return if $_SELF;
    my($prev) = Bivio::Agent::Request->get_current;
    $_SELF = shift->new;
    $_SELF->SUPER::initialize;
    Bivio::Agent::Embed::Request->clear_current
        unless $prev;
    return $_SELF
}

1;
