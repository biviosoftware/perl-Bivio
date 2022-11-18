# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::IfUserAgent;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [qw(method control_on_value ?control_off_value)];
}

sub initialize {
    my($self) = @_;
    my($method) = $self->get('method');
    my($not) = $method =~ s/^\!//;
    $self->put(
        control => [
            $not ? '!' : (),
            ['->req', 'Type.UserAgent'],
            "->$method",
        ],
    );
    return shift->SUPER::initialize(@_);
}

1;
