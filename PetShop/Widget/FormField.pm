# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Widget::FormField;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::FormField';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_label_widget {
    my($self) = @_;
    return LABEL($self->internal_get_label_value);
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # remove error widget, now included with label
    shift(@{$self->get('values')});
    return $self;
}

1;
