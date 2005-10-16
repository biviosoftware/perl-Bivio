# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldError;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::HTML::Widget::ControlBase;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('field');
}

sub internal_new_args {
    shift;
    return Bivio::UI::HTML::Widget::ControlBase->internal_new_args(
	[qw(field)],
	\@_,
    );
}

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    $self->put(
        tag => 'div',
	class => 'field_err',
	control => [
	    ['->get_request'], $self->ancestral_get('form_class'),
	    '->get_field_error', $self->get('field'),
	],
	value => [sub {
	    my($source, $model, $field, $label) = @_;
	    return Bivio::UI::Facade->get_from_request_or_self(
		$source->get_request,
	    )->get_or_default(
		'FormError', 'Bivio::UI::HTML::FormErrors',
	    )->to_html(
		$source,
		$model,
		$field,
		$label,
		$model->get_field_error($field),
	    );
	}, [['->get_request'], $self->ancestral_get('form_class')],
	   $self->get('field'),
	   $self->get_or_default('label', ''),
	],
	string_font => 0,
    );
    return shift->SUPER::initialize(@_);
}

1;

