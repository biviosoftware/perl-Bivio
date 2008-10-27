# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TupleTagSlotField;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CB) = __PACKAGE__->use('XHTMLWidget.ControlBase');
my($_INTEGER_WIDTH) = __PACKAGE__->use('Type.Integer')->get_width;

sub initialize {
    my($self) = @_;
    my($field) = $self->initialize_attr('field');
    $self->put_unless_exists(cell_class => 'field');
    $self->put(
	control => vs_form_method_call($self, 'tuple_tag_slot_label'),
	values => [
	    FormFieldError({
		field => $field,
		label => vs_form_method_call($self, 'tuple_tag_slot_label'),
	    }),
	    Director(
		[sub {
		     my($source) = @_;
		     my($m) = $self->resolve_form_model($source);
		     my($f) = $self->render_simple_attr(field => $source);
		     return $m->tuple_tag_slot_has_choices($f)
			 ? 'Select'
			 : $m->get_field_type($f)->simple_package_name;
		}],
		{
		    Date => DateField({
			field => $field,
			event_handler => DateYearHandler(),
		    }),
		    Integer => Text({
			field => $field,
			size => 9,
		    }),
		    Select => Select({
			field => $field,
			list_id_field => 'key',
			list_display_field => 'choice',
			choices => vs_form_method_call(
			    $self, 'tuple_tag_slot_choice_select_list'),
		    }),
		},
		Text({
		    field => $field,
		    size => 30,
		}),
	    ),
	],
    );
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('field');
}

sub internal_new_args {
    shift;
    return $_CB->internal_compute_new_args([qw(field ?class)], \@_);
}

1;
