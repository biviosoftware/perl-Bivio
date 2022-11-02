# Copyright (c) 2009-2010 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::CalendarEventContent;
use strict;
use Bivio::Base 'Widget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub NEW_ARGS {
    return [];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        values => [
            String(['CalendarEvent.description']),
            map(
                Join([
                    vs_text_as_prose('CalendarEventContent', $_),
                    vs_text_as_prose('CalendarEventContent', 'field_label_separator'),
                    String([$_]),
                ]),
                'time_zone',
                'CalendarEvent.location',
                'CalendarEvent.url',
            ),
        ],
        join_separator => BR(),,
    );
    return shift->SUPER::initialize(@_);
}

1;
