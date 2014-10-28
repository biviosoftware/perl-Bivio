# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Indirect;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::Widget::Indirect> adds a level of indirection to
# the rendering of widgets.  The widget which is this widget's I<value>
# is rendered dynamically by accessing this widget's attributes dynamically.
#
#
#
# value : Bivio::UI::Widget (required, dynamic)
#
# Accessed dynamically.  If the dynamic value is false, nothing is rendered.
# B<NOTE: the widget is not initialized.  You must do this yourself.>
#
# value : array_ref (required,dynamic)
#
# Accessed dynamically.  Widget value must be a widget or false.

my($_IDI) = __PACKAGE__->instance_data_index;

sub execute {
    # (self, Agent.Request) : undef
    # Executes the child widget as selected from I<req> (as source).
    my($self, $req) = @_;
    my($w) = _select($self, $req);
    Bivio::Die->die('Indirect did not select a widget; no content type')
	    unless defined($w);
    return $w->execute($req);
}

sub new {
    # (proto, hash_ref) : Widget.Indirect
    # (proto, array_ref) : Widget.Indirect
    # (proto, UI.Widget) : Widget.Indirect
    # (proto, boolean) : Widget.Indirect
    # Creates a new Indirect widget.  I<value> may be anything but a hash_ref,
    # really.  If it is a hash_ref, it must contain a I<value> attribute.
    my($proto, @args) = _new_args(@_);
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Render the indirect.  If there the widget value is false, then
    # nothing is rendered.  If the widget value is an array_ref,
    # it first calls get_widget_value to get the actual value.
    my($self, $source, $buffer) = @_;
    my($w) = _select($self, $source);
    $w->render($source, $buffer) if ref($w);
    return;
}

sub _new_args {
    # (proto, any, ...) : array
    # Returns arguments to be passed to Attributes::new.
    my($proto, $value) = @_;
    return ($proto, $value) if ref($value) eq 'HASH';
    # We accept any value
    return ($proto, {
	value => $value,
    });
}

sub _select {
    # (self, any) : UI.Widget
    # Returns the widget as directed by the source
    my($self, $source) = @_;
    my($v) = $self->get('value');
    return unless ref($v);
    return $source->get_widget_value(@$v) if ref($v) eq 'ARRAY';
    return $v;
}

1;
