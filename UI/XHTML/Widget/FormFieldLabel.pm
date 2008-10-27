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
    return $_CB->internal_compute_new_args([qw(field label ?class)], \@_);
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->put_unless_exists(
	value => Join([
	    IfFieldError(
		$self->get('field'),
		[sub {
		     my($source) = @_;
		     return vs_text(
			 $source->req,
			 $self->resolve_form_model($source)
			     ->simple_package_name,
			 'prose',
			 'error_indicator',
		     );
		}],
	    ),
	    $self->get('label'),
	]),
	cell_class => IfFieldError(
	    $self->get('field'),
	    'label label_err',
	    'label label_ok',
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
