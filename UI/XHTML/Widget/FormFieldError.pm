# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldError;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_FE) = b_use('FacadeComponent.FormError');

sub NEW_ARGS {
    return [qw(field ?class)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr(label => '');
    $self->put_unless_exists(
        tag => 'div',
	class => 'field_err',
	control => IfFieldError($self->get('field')),
	string_font => 0,
    );
    return shift->SUPER::initialize(@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($field) = $self->render_simple_attr(field => $source);
    my($model) = $self->resolve_form_model($source);
    $$buffer .= $self->render_simple_value(
	$_FE->get_from_source($source)
	    ->to_widget_value(
		$source,
		$model,
		$field,
		$self->render_simple_attr(label => $source),
		$model->get_field_error($field),
	    ),
	$source,
    );
    return;
}

1;
