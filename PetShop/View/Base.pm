# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_xhtml_adorned {
    my(@res) = shift->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(xhtml_main_left => DIV_example('hello'));
    return @res;
}

1;
