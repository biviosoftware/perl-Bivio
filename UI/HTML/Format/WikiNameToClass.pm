# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Format::WikiNameToClass;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Format';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_widget_value {
    my(undef, $wiki_name) = @_;
    $wiki_name =~ s/\W//g;
    return "body_wiki_$wiki_name";
}

1;
