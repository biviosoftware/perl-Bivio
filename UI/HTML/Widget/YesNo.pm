# Copyright (c) 2001-2009 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::YesNo;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

# Displays a Boolean field as Yes/No radios.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('values');
    $self->put(values => [
	Radio($self->get('field'), 1, 'Yes'),
	vs_blank_cell(3),
	Radio($self->get('field'), 0, 'No'),
    ]);
    return shift->SUPER::initialize(@_);
}

1;
