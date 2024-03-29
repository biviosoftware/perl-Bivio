# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::AuxiliaryForm;
use strict;
use Bivio::Base 'HTMLWidget.Form';


sub control_off_render {
    my($self, $source) = @_;
    $self->get('form_class')->new($source->req)->process;
    return shift->SUPER::control_on_render(@_);
}

sub initialize {
    my($self) = @_;
    my(@res) = shift->SUPER::initialize(@_);
    $self->put_unless_exists(control => sub {
        return ['->ureq', $self->get('form_class')];
    });
    return @res;
}

1;
