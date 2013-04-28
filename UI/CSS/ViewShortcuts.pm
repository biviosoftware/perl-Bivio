# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::ViewShortcuts;
use strict;
use Bivio::Base 'UI.ViewShortcuts';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub view_autoload {
    my($proto, undef, $args, $simple_method) = @_;
    if ($simple_method =~ /^[A-Z]/) {
	my($fc) = b_use('Agent.Request')->get_current_or_die->get('UI.Facade')
	    ->unsafe_get($simple_method);
	return $fc->format_css(@$args)
	    if $fc
    }
    return shift->SUPER::view_autoload(@_);
}

sub vs_add {
    shift;
    return [sub {$_[1] + $_[2]}, @_];
}

1;
