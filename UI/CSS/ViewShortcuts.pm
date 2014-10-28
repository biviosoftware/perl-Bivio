# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::ViewShortcuts;
use strict;
use Bivio::Base 'UI.ViewShortcuts';


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

sub vs_color {
    my($proto, $name) = @_;
    return [
	b_use('FacadeComponent.Color'),
 	'->format_html', $name, undef, ['->req'],
    ];
}

sub vs_lighter_color {
    my($proto, $color, $amount) = @_;
    return [
	sub {
	    my($source, $value, $amount) = @_;
	    $value =~ s/([0-9a-f]{2})/_lighten($1, $amount)/ieg;
	    return $value;
	},
	$color,
	$amount,
    ];
}

sub _lighten {
    my($value, $amount) = @_;
    $value = hex($value) + ($amount || 0x1c);
    if ($value > 255) {
	$value = 255;
    }
    elsif ($value < 0) {
	$value = 0;
    }
    return sprintf("%02X", $value);
}

1;
