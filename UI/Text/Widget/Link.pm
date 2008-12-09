# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Text::Widget::Link;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Die;

# C<Bivio::UI::Text::Widget::Link> implements a text http: link.
#
#
#
# value : any (required)
#
# Value to use for the uri.  If I<value> is a valid enum name or is an actual
# TaskId instance, I<value> will be treated as a task.  Otherwise, I<value> will
# be treated as a literal uri.  If value is in all capital letters, then it is
# treated as a task id, and a widget value for format_stateless_uri() will be
# used.
#
# If I<value> is an array_ref, it will be dereferenced and passed to
# C<$source-E<gt>get_widget_value> to get the uri to use.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    # (self) : undef
    # Partially initializes by copying attributes to fields.
    # It is fully initialized after first render.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{value};

    $fields->{value} = _initialize_value($self);
    return $self->SUPER::initialize();
}

sub internal_new_args {
    # (proto, proto, any) : hash_ref
    # Implements positional argument parsing for L<new|"new">.
    my(undef, $value, $attributes) = @_;
    return '"value" must be defined' unless defined($value);
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    # (proto, any, hash_ref) : Widget.Link
    # (proto, hash_ref) : Widget.Link
    # Creates a C<Link> widget with attributes I<value>.
    # And optionally, set extra I<attributes>.
    #
    #
    # If I<attributes> supplied, creates with attribute (name, value) pairs.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Render the absolute URI.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($v) = $self->render_value('value', $fields->{value}, $source);
    # Insert http: prefix, if not already there.
    $$buffer .= $source->get_request->format_http_prefix
	unless $$v =~ /^\w+:/;
    $$buffer .= $$v;
    return;
}

sub _initialize_value {
    # (self) : any
    # Returns the value as initialized.
    # 
    # TODO: Share this code with HTML::Link
    my($self) = @_;
    my($value) = $self->initialize_attr('value');
    if (ref($value)) {
	return $value if ref($value) eq 'ARRAY';
	$self->die('value', undef, 'unknown type for value: ', $value)
		unless ref($value) eq 'Bivio::Agent::TaskId';
	return [['->get_request'], '->format_stateless_uri',
	    Bivio::Agent::TaskId->$value()];
    }
    return [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$value()]
	    if Bivio::Agent::TaskId->is_valid_name($value);
    return $value;
}

1;
