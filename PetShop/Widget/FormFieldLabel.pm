# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Widget::FormFieldLabel;
use strict;
use Bivio::Base 'Bivio::UI::XHTML::Widget::FormFieldLabel';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put(value => Grid([[
    	IfFieldError(
    	    $self->get('field'),
    	    Join([
    		DIV_error_bubble(Join([
    		    FormFieldError({
    			field => $self->get('field'),
    			label => $self->get('label')->get('value'),
    		    }),
    		])),
    	    ]),
    	)->put(cell_class => 'error_bubble'),
    	IfFieldError(
    	    $self->get('field'),
    	    DIV_error_arrow_holder(Join([
    		SPAN_error_arrow_border(),
    		SPAN_error_arrow(),
    	    ])),
    	)->put(cell_class => 'error_arrow'),
	$self->get('label')->put(cell_class => 'label label_ok'),
    ]], {
    	class => 'label_group',
    }));
    $self->put(cell_class => '');
    return shift->SUPER::initialize(@_);
}

1;
