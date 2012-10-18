# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::CSS;
use strict;
use Bivio::Base 'FacadeComponent.Constant';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub REGISTER_PREREQUISITES {
    return ['Constant'];
}

sub format_css {
    return Prose(shift->get_value(@_));
}

1;
