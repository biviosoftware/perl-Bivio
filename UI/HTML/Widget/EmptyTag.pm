# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::EmptyTag;
use strict;
use Bivio::Base 'HTMLWidget.Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	tag_if_empty => 1,
	value => '',
    );
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('tag', 'class');
}

sub internal_new_args {
    return shift->internal_compute_new_args(['tag', '?class'], \@_);
}

1;
