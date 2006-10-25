# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Example;
use strict;
use base 'Bivio::UI::View::Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub eg1 {
    view_put(body => Simple('hello, world!'));
    return;
}

1;
