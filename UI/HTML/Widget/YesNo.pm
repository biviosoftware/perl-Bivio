# Copyright (c) 2001-2009 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::YesNo;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

# Displays a Boolean field as Yes/No radios.


sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('values');
    my($attrs) = {
        map($self->unsafe_get($_)
                ? ($_ => $self->get($_))
                : (),
                qw(event_handler)),
    };    
    $self->put(values => [
	Radio($self->get('field'), 1, 'Yes', $attrs),
	vs_blank_cell(3),
	Radio($self->get('field'), 0, 'No', $attrs),
    ]);
    return shift->SUPER::initialize(@_);
}

1;
