# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::ViewLanguageAUTOLOAD;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
our($_CALLING_CONTEXT);
our($_CALLING_CONTEXT_METHOD);
my($_A) = b_use('IO.Alert');
my($_VL);

sub AUTOLOAD {
    local($_CALLING_CONTEXT) = $_A->calling_context;
    local($_CALLING_CONTEXT_METHOD) = $AUTOLOAD =~ /(\w+)$/;
    $_VL ||= b_use('UI.ViewLanguage');
    return $_VL->call_method($AUTOLOAD, $_VL, @_);
}

sub import {
    my($pkg) = caller();
    no strict qw(refs);
    *{$pkg.'::AUTOLOAD'} = \&AUTOLOAD;
    return;
}

sub unsafe_calling_context {
    return undef
	unless (caller)[0]->simple_package_name
        eq ($_CALLING_CONTEXT_METHOD || '');
    return $_CALLING_CONTEXT || b_die('no calling context');
}

1;
