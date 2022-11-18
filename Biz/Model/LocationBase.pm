# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::LocationBase;
use strict;
use Bivio::Base 'Biz.PropertyModel';

my($_L) = b_use('Type.Location');
my($_DEFAULT_LOCATION) = $_L->get_default;

sub DEFAULT_LOCATION {
    return $_DEFAULT_LOCATION;
}

sub create {
    my($self, $values) = @_;
    $values->{location} ||= $_DEFAULT_LOCATION;
    $values->{realm_id} ||= $self->req('auth_id');
    return $self->SUPER::create($values);
}

sub execute_load_home {
    my($proto, $req) = @_;
    $proto->new($req)->load({
        location => $_L->HOME,
    });
    return 0;
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
