# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::Opacity;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [qw(opacity)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        value => Join([
            'opacity:', $self->get('opacity'), ';', "\n",
            'filter:alpha(opacity=', int($self->get('opacity') * 100), ');', "\n",
        ]),
    );
    return;
}

1;
