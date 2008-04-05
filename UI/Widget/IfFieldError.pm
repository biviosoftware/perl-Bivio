# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::IfFieldError;
use strict;
use Bivio::Base 'Widget.If';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::ViewShortcuts';

sub internal_as_string {
    return shift->unsafe_get('field');
}

sub internal_new_args {
    my(undef, $field, $on, $off, $attributes) = @_;
    return {
	field => $field,
	defined($on) ? (control_on_value => $on) : (),
	defined($off) ? (control_off_value => $off) : (),
	($attributes ? %$attributes : ()),
    };
}
sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->initialize_attr(control_on_value => 1);
    $self->put_unless_exists(
	control => $_VS->vs_form_method_call($self, 'get_field_error'));
    return shift->SUPER::initialize(@_);
}

1;
