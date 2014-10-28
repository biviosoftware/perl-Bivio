# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLink;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [qw(facade_label ?class)];
}

sub initialize {
    my($self) = @_;
    my($l) = $self->initialize_attr('facade_label');
    $self->put_unless_exists(
	tag => 'a',
	value => XLinkLabel($l),
	href => XLinkURI($l),
	html_attrs => vs_html_attrs_merge([qw(href name link_target)]),
    );
    return shift->SUPER::initialize(@_);
}

1;
