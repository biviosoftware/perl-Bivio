# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::InlineCSS;
use strict;
use Bivio::Base 'HTMLWidget.Tag';
b_use('UI.ViewLanguageAUTOLOAD');


sub NEW_ARGS {
    return [qw(value)];
}

sub initialize {
    my($self) = @_;
    $self->put(
	tag => 'style',
	TYPE => 'text/css',
    );
#TODO: Consider compression
    return shift->SUPER::initialize(@_);
}

1;
