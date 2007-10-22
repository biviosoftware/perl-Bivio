# Copyright (c) 2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::WithModel;
use strict;
use Bivio::Base 'Widget.With';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_new_args {
    my(undef, $model_class, $value, $attributes) = @_;
    return {
	model_class => $model_class,
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub initialize {
    my($self) = @_;
    $self->put(source => [sub {
        return shift->req(
	    Bivio::Biz::Model->get_instance(shift(@_))->package_name,
	);
    }, $self->get('model_class')]);
    return shift->SUPER::initialize(@_);
}

1;
