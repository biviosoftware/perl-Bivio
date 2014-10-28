# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::JavaScriptString;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';


sub NEW_ARGS {
    return ['value'];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($x) = $self->render_simple_attr('value', $source);
    $x =~ s/([\\\"\'])/\\$1/sg;
    $$buffer .= '"';
    $$buffer .= $x;
    $$buffer .= '"';
    return;
}

1;
