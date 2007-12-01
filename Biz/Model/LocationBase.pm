# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::LocationBase;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DEFAULT_LOCATION) = Bivio::Type->get_instance('Location')->get_default;

sub DEFAULT_LOCATION {
    return $_DEFAULT_LOCATION;
}

sub create {
    my($self, $values) = @_;
    # Sets I<location> if not set, then calls SUPER.
    $values->{location} ||= $_DEFAULT_LOCATION;
    $values->{realm_id} ||= $self->get_request->get('auth_id');
    return $self->SUPER::create($values);
}

sub internal_unique_load_values {
    my($self, $values) = @_;
    return {
	map(($_ => $values->{$_} || return),
	    'realm_id',
	),
	location => $values->{location} || $_DEFAULT_LOCATION,
    };
}

sub unauth_load {
    my($self) = shift;
    # If I<realm_id> is set and I<location> isn't, sets I<location> to I<HOME>
    # and calls SUPER.
    my($query) = int(@_) == 1 ? @_ : {@_};
    $query->{location} = $_DEFAULT_LOCATION
	if !$query->{location} && $query->{realm_id};
    return $self->SUPER::unauth_load($query);
}

1;
