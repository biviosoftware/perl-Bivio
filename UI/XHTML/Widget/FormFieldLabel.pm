# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_CB) = b_use('XHTMLWidget.ControlBase');
my($_IS_HTML5) = b_use('UI.Facade')->is_html5;

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
	value => $_IS_HTML5
	    ? _error_bubble($self)
	    : _error_indicator($self)
	);
    return shift->SUPER::initialize(@_);
}

sub _error_bubble {
    my($self) = @_;
    $self->put(cell_class => 'label');
    return Grid([[
    	IfFieldError(
    	    $self->get('field'),
    	    Join([
    		DIV_b_error_bubble(Join([
    		    FormFieldError({
    			field => $self->get('field'),
    			label => $self->get('label')->get('value'),
    		    }),
    		])),
    	    ]),
    	)->put(cell_class => 'b_error_bubble'),
    	IfFieldError(
    	    $self->get('field'),
    	    DIV_b_error_arrow_holder(Join([
    		SPAN_b_error_arrow_border(),
    		SPAN_b_error_arrow(),
    	    ])),
    	)->put(cell_class => 'b_error_arrow'),
	$self->get('label')->put(cell_class => 'label label_ok'),
    ]], {
    	class => 'b_label_group',
    });
}

sub _error_indicator {
    my($self) = @_;
    $self->put(cell_class => IfFieldError(
	$self->get('field'),
	'label label_err',
	'label label_ok',
    ));
    return Join([
	IfFieldError(
	    $self->get('field'),
	    [sub {
		 my($source) = @_;
		 return vs_text(
		     $source->req,
		     $self->resolve_form_model($source)->simple_package_name,
		     'prose',
		     'error_indicator',
		 );
	     }],
	),
	$self->get('label'),
    ]);
}

1;
