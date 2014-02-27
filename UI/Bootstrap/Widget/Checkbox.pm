# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::Checkbox;
use strict;
use Bivio::Base 'HTMLWidget.Checkbox';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    shift->SUPER::initialize(@_);
    $self->put(class => 'b_checkbox');
    return;
}

1;
