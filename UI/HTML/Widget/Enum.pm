# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Enum;
use strict;
use Bivio::Base 'HTMLWidget.String';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return ['field'];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
#TODO: enable a lookup on the value
	value => [$self->get('field'), '->get_short_desc'],
    );
    return shift->SUPER::initialize(@_);
}

1;
