# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Prose';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CB) = __PACKAGE__->use('XHTMLWidget.ControlBase');

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('field');
}

sub internal_new_args {
    shift;
    return $_CB->internal_compute_new_args([qw(field label)], \@_);
}

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    my($class) = $self->ancestral_get('form_class');
    my($field) = $self->ancestral_get('field');
    $self->put(
	value => Join([
	    If([['->req', $class], '->get_field_error', $field],
	       vs_text(
		   $class->simple_package_name, 'prose', 'error_indicator')),
	    $self->get('label'),
	]),
	cell_class => [
	    sub {$_[1] ? 'label_err' : 'label_ok'},
	    [['->req', $class], '->get_field_error', $field],
	],
    );
    return shift->SUPER::initialize(@_);
}

1;
