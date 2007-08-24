# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	class => 'rounded_box',
    )->put(
        value => Join([
	    map(
		Tag(div =>
		    $_ eq 'rounded_box_body' ? $self->get('value') : '',
		    $_,
		    {tag_if_empty => 1}),
		qw(top_left top_right rounded_box_body bottom_left bottom_right),
	    ),
	]),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->SUPER::internal_new_args(div => @_);
}

1;

