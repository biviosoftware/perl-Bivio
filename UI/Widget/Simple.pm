# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Simple;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return '"value" must be defined'
	unless defined($value);
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub render {
    shift->render_attr('value', @_);
    return;
}

1;
