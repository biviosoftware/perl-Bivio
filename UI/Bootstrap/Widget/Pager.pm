# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::Pager;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    my($list) = $self->get('list_class');
    return shift->put_unless_exists(
	tag => 'ul',
	class => 'pagination pull-right',
	value => Join([
	    _link($list, 'prev'),
	    _link($list, 'next'),
	]),
	control => If(
	    Or(_has_query($list, 'prev'), _has_query($list, 'next')),
	    1,
	    0,
	),
    )->SUPER::initialize(@_);
}

sub _has_query {
    my($list, $dir) = @_;
    return [["Model.$list", '->get_query'], "has_$dir"];
}

sub _link {
    my($list, $dir) = @_;
    return LI(
	Link(
	    LinkIcon("pager_$dir"),
	    ["Model.$list", '->format_uri', uc("${dir}_LIST")],
	    '/',
	),
	If(_has_query($list, $dir),
	   '',
	   'disabled',
        ),
    );
}

1;
