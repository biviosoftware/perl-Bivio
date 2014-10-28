# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Simple;
use strict;
use Bivio::Base 'Widget.ControlBase';


sub NEW_ARGS {
    return [qw(value)];
}

sub execute {
    my($self, $req) = @_;
    # DOES NOT CONFORM TO Task executable
    my($buffer) = '';
    $self->render($req, \$buffer);
    return \$buffer;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    return shift->SUPER::initialize(@_);
}

sub control_on_render {
    shift->render_attr('value', @_);
    return;
}

1;
