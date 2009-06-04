# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::JavaScript::Widget::QuotedValue;
use strict;
use Bivio::Base 'Widget.Simple';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('is_initialized');
    $self->put(is_initialized => 1);
    $self->put(value => [sub {
        my(undef, $value) = @_;
 	$value =~ s/"/\\"/g;
 	return "\"$value\",\n";
    }, $self->get('value')]);
    return shift->SUPER::initialize(@_);
}

1;
