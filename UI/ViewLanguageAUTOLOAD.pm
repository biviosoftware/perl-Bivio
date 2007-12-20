# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::ViewLanguageAUTOLOAD;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub AUTOLOAD {
    return Bivio::UI::ViewLanguage->call_method(
	$AUTOLOAD, 'Bivio::UI::ViewLanguage', @_,
    );
}

sub import {
    my($pkg) = caller();
    no strict qw(refs);
    *{$pkg.'::AUTOLOAD'} = \&AUTOLOAD;
    return;
}

1;
