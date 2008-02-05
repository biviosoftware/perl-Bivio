# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RoundedBox;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($x);
    foreach my $c (qw(
	 rounded_box_body
	 bottom_right
	 bottom_left
	 top_right
	 top_left
    )) {
	$x = Tag(
	    'div',
	    $x || $self->get('value'),
	    $c,
	);
    }
    $self->put_unless_exists(
	class => 'rounded_box',
    )->put(
        value => $x,
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->SUPER::internal_new_args(div => @_);
}

1;

