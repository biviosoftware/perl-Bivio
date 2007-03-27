# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::ViewShortcuts;
use strict;
use Bivio::Base 'Bivio::UI::ViewShortcuts';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub view_autoload {
    my($proto, $method, $args) = @_;
    if ($method =~ /^[A-Z]/) {
	my($fc) = Bivio::Agent::Request->get_current->get('Bivio::UI::Facade')
	    ->unsafe_get($method);
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
