# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TaskMenuOverride;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_ATTR_KEY) = __PACKAGE__ . 'attr';

sub NEW_ARGS {
    return [qw(value attrs)];
}

sub control_on_render {
    my($self, $source) = @_;
    $source->req->put($_ATTR_KEY => $self->get('attrs'));
    shift->SUPER::control_on_render(@_);
    $source->req->delete($_ATTR_KEY);
    return;
}

sub unsafe_get_override_attributes {
    my($self, $source) = @_;
    my($res) = $source->ureq($_ATTR_KEY);
    $source->req->delete($_ATTR_KEY)
        if $res;
    return $res;
}

1;
