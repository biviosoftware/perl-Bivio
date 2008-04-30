# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLinkLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->initialize_attr(_prose => Prose([sub {
	my($source) = @_;
        return vs_text(
	    $source->req,
	    'xlink',
	    $self->render_simple_attr('value', $source),
	);
    }]));
    return shift->SUPER::initialize(@_);
}

sub render {
    shift->render_attr(_prose => @_);
    return;
}

1;
