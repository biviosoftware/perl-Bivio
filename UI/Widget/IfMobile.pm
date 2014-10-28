# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::IfMobile;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [qw(control_on_value ?control_off_value)];
}

sub REQ_KEY {
    return __PACKAGE__;
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(control => ['->ureq', $self->REQ_KEY]);
    return shift->SUPER::initialize(@_);
}

sub is_mobile {
    my($proto, $req) = @_;
    return $req->ureq($proto->REQ_KEY) ? 1 : 0;
}

1;
