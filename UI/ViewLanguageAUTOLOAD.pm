# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::ViewLanguageAUTOLOAD;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
my($_VL) = b_use('UI.ViewLanguage');

sub AUTOLOAD {
    return $_VL->call_method($AUTOLOAD, 'Bivio::UI::ViewLanguage', @_);
}

sub import {
    my($pkg) = caller();
    no strict qw(refs);
    *{$pkg.'::AUTOLOAD'} = \&AUTOLOAD;
    return;
}

1;
