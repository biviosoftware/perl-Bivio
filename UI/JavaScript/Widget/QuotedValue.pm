# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::JavaScript::Widget::QuotedValue;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($v) = $self->render_simple_attr(value => $source);
    $v =~ s/"/\\"/g;
    $$buffer .= qq{"$v"};
    return;
}

1;
