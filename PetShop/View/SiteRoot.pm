# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::SiteRoot;
use strict;
use Bivio::Base 'View';
b_use('UI.ViewLanguageAUTOLOAD');


sub hm_bunit1 {
    return shift->internal_body(Simple('bunit1'));
}

1;
