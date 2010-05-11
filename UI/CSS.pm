# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS;
use strict;
use Bivio::Base 'FacadeComponent.Constant';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Agent.Request');

sub format_css {
    return Prose(shift->get_value(@_));
}

1;
