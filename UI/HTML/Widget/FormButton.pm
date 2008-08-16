# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormButton;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';

# C<Bivio::UI::HTML::Widget::FormButton> a form specific submit button.
#
# Font is always C<FORM_SUBMIT>.
#
#
#
# attributes : string []
#
# Attributes to be applied to the button.  C<StandardSubmit>
# uses this to set "onclick=reset()".
#
# field : string (required)
#
# Name of the form field.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# label : string [Model.field]
#
# String label to use.
#
# label : array_ref
#
# If specified, the button text will be determined by calling
# L<get_widget_value|"get_widget_value"> on the rendering source.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_F) = b_use('FacadeComponent.Font');

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($p, $s) = $_F->format_html('form_submit', $source);
    my($a) = $self->render_simple_attr('attributes', $source);
    $a = " $a"
	if $a && $a =~ /^\S/;
    $$buffer .= $p
	. '<input type="submit" name="'
	. $self->resolve_ancestral_attr('form_model', $source->get_request)
	    ->get_field_name_for_html($self->get('field'))
	. '" value="'
	. Bivio::HTML->escape_attr_value(
	    $self->render_simple_attr('label', $source))
	. '"'
	. $a;
    $self->SUPER::control_on_render($source, $buffer);
    $$buffer .= " />$s";
    return;
}

sub initialize {
    my($self) = shift;
    $self->put_unless_exists(label => sub {
	$_VS->vs_text(
	    $self->ancestral_get('form_class')->simple_package_name,
	    $self->get('field'),
	);
    })->map_invoke(
	unsafe_initialize_attr => [qw(label attributes)],
    );
    return $self->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(field)], \@_);
}

1;
