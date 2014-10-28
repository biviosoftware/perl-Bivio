# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::JavaScript::Widget::QuotedValue;
use strict;
use Bivio::Base 'UI.Widget';


sub NEW_ARGS {
    return [qw(value)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $self->escape_value($self->render_simple_attr(value => $source));
    return;
}

sub escape_value {
    my(undef, $v) = @_;
    $v =~ s/"/\\"/g;
    $v =~ s/\r?\n/\\n/sg;
    return qq{"$v"};
}

1;
