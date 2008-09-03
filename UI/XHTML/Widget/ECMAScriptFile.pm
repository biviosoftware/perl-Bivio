# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ECMAScriptFile;
use strict;
use Bivio::Base 'HTMLWidget.ECMAScript';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_new_args {
    return shift->internal_compute_new_args(['SRC'], \@_);
}

1;
