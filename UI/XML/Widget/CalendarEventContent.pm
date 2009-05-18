# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XML::Widget::CalendarEventContent;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(value => b_use('HTMLWidget.String')->new({
	hard_newlines => 1,
	escape_html => 1,
	value => Join([
	    ['CalendarEvent.description'],
	    map(Join([
		Prose(vs_text("CalendarEventList.$_")),
		': ',
		$_ =~ /zone/ ? [$_, '->get_short_desc'] : [$_],
	    ], {
		control => [$_],
	    }), map("CalendarEvent.$_", qw(location url time_zone))),
	], "\n"),
    }));
    return shift->SUPER::initialize(@_);
}

1;
