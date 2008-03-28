# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::JoinMenu;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(join_separator => sub {SPAN_want_sep('')});
    return shift->SUPER::initialize(@_);
}

1;
