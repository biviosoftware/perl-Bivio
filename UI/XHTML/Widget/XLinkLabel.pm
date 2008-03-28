# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLinkLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->initialize_attr(
	_prose => Prose(vs_text(xlink => ['->req', "$self"])));
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    $self->SUPER::render($source, \$b);
    my($req) = $self->req;
    $req->put("$self" => $b);
    $self->get('_prose')->render($source, $buffer);
    return;
}

1;
