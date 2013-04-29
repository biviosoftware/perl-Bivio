# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::ViewLanguageAUTOLOAD;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
our($_CALLING_CONTEXT);
our($_CALLING_CONTEXT_METHOD);
my($_A) = b_use('IO.Alert');

sub AUTOLOAD {
    return b_use('UI.ViewLanguageAUTOLOAD')->call_autoload($AUTOLOAD, \@_);
}

sub call_autoload {
    my($proto, $method, $args, $calling_context) = @_;
    local($_CALLING_CONTEXT) = $calling_context || b_use('UI.ViewLanguageAUTOLOAD')->widget_new_calling_context;
    local($_CALLING_CONTEXT_METHOD) = $method;
    return b_use('UI.ViewLanguage')->call_method($method, b_use('UI.ViewLanguage'), $args);
}

sub widget_new_calling_context {
    return $_A->calling_context([qr{::Widget$|WidgetFactory|ViewShortcuts|ViewLanguage|UI::View$|ClassLoader$}]);
}

sub import {
    my($pkg) = caller();
    no strict qw(refs);
    *{$pkg.'::AUTOLOAD'} = \&AUTOLOAD;
    return;
}

sub unsafe_calling_context {
    return $_CALLING_CONTEXT;
}

sub unsafe_calling_context_for_wiki_text {
    return undef
	unless $_CALLING_CONTEXT_METHOD
	&& (caller)[0]->simple_package_name
        eq ($_CALLING_CONTEXT_METHOD =~ /(\w+)$/)[0];
    return $_CALLING_CONTEXT || b_die('no calling context');
}

1;
