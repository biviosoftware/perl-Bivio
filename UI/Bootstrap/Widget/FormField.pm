# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::FormField;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub internal_get_label_widget {
    my($self) = @_;
    return $self->internal_get_label_value;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # error label goes under widget
    my($values) = [reverse(@{$self->get('values')})];
#TODO: assumes widget is Tag baseclass
    my($edit) = $values->[0];
    $edit->put(class => 'form-control')
        unless $edit->isa('Bivio::UI::HTML::Widget::File');
    return $self->put(values => $values);
}

1;
