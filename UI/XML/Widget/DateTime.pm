# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::DateTime;
use strict;
use Bivio::Base 'XMLWidget.Simple';

my($_DT) = b_use('Type.DateTime');

sub NEW_ARGS {
    return [qw(value ?conversion_method)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr(conversion_method => 'to_xml');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($method) = ${$self->render_attr(conversion_method => $source)};
    $$buffer .= $_DT->$method(${$self->render_attr('value', $source)});
    return;
}

1;
