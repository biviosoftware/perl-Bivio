# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ForumDropDown;
use strict;
use Bivio::Base 'XHTMLWidget.RealmDropDown';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub DEFAULT_REALM_TYPES {
    return ['FORUM'];
}

1;
