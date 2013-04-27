# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::t::View::T1;
use strict;
use base 'Bivio::UI::View::Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub pre_compile {
    # Override setting "base" in Method
    return;
}

sub t1_html {
    view_class_map('HTMLWidget');
    view_main(SimplePage('t1'));
    return;
}

1;
