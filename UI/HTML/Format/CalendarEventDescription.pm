# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::CalendarEventDescription;
use strict;
use base 'Bivio::UI::HTML::Format';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_widget_value {
    my($self, $raw) = @_;
    my($v) = Bivio::HTML->escape($raw);
    # Basic fixup based on observed Sunbird iCal output
#    $v =~ s{ *\\n}{<br />}mg;
    $v =~ s/ *\\n/ /mg;
    $v =~ s/\\,/,/mg;
    return $v;
}

1;
