# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::FormFieldError;
use strict;
use Bivio::Base 'Bivio::UI::XHTML::Widget::FormFieldError';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(
        tag => 'ul',
        class => 'b_form_field_error',
    )->SUPER::initialize(@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    $$buffer .= '<li>';
    shift->SUPER::render_tag_value(@_);
    $$buffer .= '</li>';
    return;
}

1;
