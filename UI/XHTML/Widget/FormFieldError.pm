# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldError;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('UI.Facade');

sub internal_new_args {
    shift;
    return Bivio::UI::HTML::Widget::ControlBase->internal_compute_new_args(
	[qw(field)],
	\@_,
    );
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
    $$buffer .= ($_F->get_from_request_or_self($source->req)
	->unsafe_get('FormError')
        || $self->use('Bivio::UI::HTML::FormErrors')
    )->to_html(
	$source,
	$model,
	$field,
	$self->render_simple_attr(label => $source),
	$model->get_field_error($field),
    );
    return;
}

1;

