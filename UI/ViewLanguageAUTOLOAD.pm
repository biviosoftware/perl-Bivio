# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::ViewLanguageAUTOLOAD;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($AUTOLOAD);
our($_CALLING_CONTEXT);
our($_CALLING_CONTEXT_METHOD);
my($_A) = b_use('IO.Alert');
my($_VLA) = b_use('UI.ViewLanguageAUTOLOAD');
my($_VL) = b_use('UI.ViewLanguage');

sub AUTOLOAD {
    return $_VLA->call_autoload($AUTOLOAD, \@_);
}

sub call_autoload {
    my($proto, $method, $args, $calling_context) = @_;
    local($_CALLING_CONTEXT) = $calling_context || $_VLA->widget_new_calling_context;
    local($_CALLING_CONTEXT_METHOD) = $method;
    return $_VL->call_method($method, $_VL, $args);
}

sub handle_class_loader_require {
    my($proto, $pkg) = @_;
    ($pkg || $proto->my_caller)->replace_subroutine(AUTOLOAD => \&AUTOLOAD);
    return;
}

sub import {
    return shift->handle_class_loader_require((caller())[0]);
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

sub widget_new_calling_context {
    return $_A->calling_context([qr{::Widget$|WidgetFactory|ViewShortcuts|ViewLanguage|UI::View$|ClassLoader$}]);
}

1;
