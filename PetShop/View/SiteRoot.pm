# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::SiteRoot;
use strict;
use Bivio::Base 'Bivio::UI::View::SiteRoot';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub hm_bunit1 {
    return shift->internal_body(Simple('bunit1'));
}

1;
