# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::StandardSubmit;
use strict;
use Bivio::Base 'HTMLWidget.Grid';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::StandardSubmit> Draws buttons associated with
# the form. By default, the ok_button and cancel_button are rendered. Use
# the buttons attribute to display an alternative.
#
#
#
# buttons : array_ref []
#
# The buttons to render. If not specified, then ok_button and cancel_button
# are rendered.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# labels : hash_ref []
#
# Mapping of button field names to labels. A button label defaults to its
# field name.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_SEPARATION) = 10;

sub initialize {
    # (self) : undef
    # Initialize grid.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{initialized};
    $fields->{initialized} = 1;

    # load the grid with buttons
    my($values) = [];
    my($buttons) = $self->unsafe_get('buttons')
	    || ['ok_button', 'cancel_button'];

    my($factory) = 'Bivio::UI::HTML::WidgetFactory';
    Bivio::IO::ClassLoader->simple_require($factory);
    my($form) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('form_class'));
    my($labels) = $self->unsafe_get('labels') || {};

    foreach my $button (reverse(@$buttons)) {
	unshift(@$values, $factory->create(ref($form).".$button", {
	    attributes => $form->get_field_type($button)->isa(
		    'Bivio::Type::CancelButton')
	            ? 'onclick="reset()"'
	            : '',
	    label => vs_text($form->simple_package_name,
		    $labels->{$button} || $button),
	}));
	unshift(@$values,
		ClearDot()->as_html($_SEPARATION))
		unless $button eq $buttons->[0];
    }

    $self->put(values => [$values]);
    $self->SUPER::initialize;
    return;
}

sub internal_new_args {
    # (proto, any, ...) : any
    # Implements positional argument parsing for L<new|"new">.
    my(undef, $buttons, $attributes) = @_;
    return '"buttons" attribute must be defined' unless defined($buttons);
    return '"buttons" must be an array_ref' unless ref($buttons) eq 'ARRAY';
    return {
	buttons => $buttons,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    # (proto, array_ref, hash_ref) : Widget.StandardSubmit
    # (proto, hash_ref) : Widget.StandardSubmit
    # List of I<buttons> can be supplied with options I<attributes>.
    #
    #
    # Creates a new StandardSubmit widget from I<attributes>.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

1;
