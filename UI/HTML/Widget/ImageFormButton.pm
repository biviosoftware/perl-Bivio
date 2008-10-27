# Copyright (c) 2000-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ImageFormButton;
use strict;
use base 'Bivio::UI::HTML::Widget::ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $self->get_request;
    my($field) = $self->resolve_ancestral_attr('form_model', $req)
	->get_field_name_for_html(${$self->render_attr('field', $source)});
    my($super) = '';
    my($alt) = $self->render_simple_attr('alt', $source);
    $self->SUPER::control_on_render($source, \$super);
    $$buffer .= '<input type="image" name="'
	. $field
	. '" src="'
	. Bivio::UI::Icon->get_value(
	    ${$self->render_attr('image', $source)}, $req)->{uri}
	. (length($alt) ? '" alt="' . Bivio::HTML->escape_attr_value($alt) : '')
	. ($super =~ /id=/ ? '' : ('" id="' . $field))
	. ($super =~ /class=/ ? '' : '" border="0')
	. '"'
	. $super
	. $self->render_simple_attr('attributes', $source)
        . ' />';
    return;
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	field => sub {
	    Bivio::IO::Alert->warn_deprecated('field must be specified');
	    return 'submit';
	});
    $self->map_invoke(initialize_attr => [qw(field image)]);
    $self->map_invoke(unsafe_initialize_attr => [qw(alt attributes)]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(field image ?class)], \@_);
}

1;
