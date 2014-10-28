# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::If2014Style;
use strict;
use Bivio::Base 'Widget.If';
b_use('UI.ViewLanguageAUTOLOAD');


sub NEW_ARGS {
    return [qw(control_on_value ?control_off_value)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control => [[qw(->ureq UI.Facade)], '->is_2014style']);
    return shift->SUPER::initialize(@_);
}

1;
