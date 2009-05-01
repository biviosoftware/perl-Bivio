# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Simple;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    return shift->initialize_attr('value');
}

sub render {
    shift->render_attr('value', @_);
    return;
}

1;
