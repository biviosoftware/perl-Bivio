# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::FormButton;
use strict;
use Bivio::Base 'XHTMLWidget.InputBase';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        TYPE => 'submit',
    );
    return shift->put(
        tag => 'button',
        VALUE => 1,
        value => vs_text_as_prose(
            $self->ancestral_get('form_class')->simple_package_name,
            $self->get('field'),
        ),
        class => $self->internal_class_with_additional(
            $self->get('field') eq 'ok_button'
                ? 'btn btn-primary'
                : 'btn btn-default',
        ),
    )->SUPER::initialize(@_);
}

1;
