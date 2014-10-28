# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::ViewSupport;
use strict;
use Bivio::Base 'FacadeComponent.Constant';
b_use('IO.ClassLoaderAUTOLOAD');

my($_IDI) = __PACKAGE__->instance_data_index;

sub view_cache_delete {
    my($proto, $key, $facade) = @_;
    delete(_cache($proto, $facade)->{$key});
    return;
}

sub initialization_complete {
    my($self) = @_;
    $self->[$_IDI] = {};
    return shift->SUPER::initialization_complete(@_);
}

sub view_cache_put {
    my($proto, $key, $value, $facade) = @_;
    _cache($proto, $facade)->{$key} = $value;
    return;
}

sub view_cache_unsafe_get {
    my($proto, $key, $facade) = @_;
    return _cache($proto, $facade)->{$key};
}

sub _cache {
    my($proto, $facade) = @_;
    return $facade->get($proto->simple_package_name)->[$_IDI];
}

1;
