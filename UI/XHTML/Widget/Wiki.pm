# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Wiki;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	tag => 'DIV',
	class => 'wiki',
	value => '',
	tag_if_empty => 0,
    );
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return;
}

sub internal_new_args {
    return shift->internal_compute_new_args([], \@_);
}

sub render_tag_value {
    my(undef, $source, $buffer) = @_;
    my($req) = $source->req;
    $$buffer .= $req->get('Action.WikiView')->render_html($req);
    return;
}

1;
