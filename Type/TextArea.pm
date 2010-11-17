# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::TextArea;
use strict;
use Bivio::Base 'Type.Text';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LINE_WIDTH {
    return 60;
}

sub from_literal {
    my($proto, $value, $line_width) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
 	unless defined($value) && length($value);
    my($pref, $req);
    return $proto->wrap_lines($value, $line_width || $proto->LINE_WIDTH)
	if defined($value)
        and $req = Bivio::Agent::Request->get_current
	and Bivio::Auth::Support
	    ->unsafe_get_user_pref('TEXTAREA_WRAP_LINES', $req, \$pref)
        and $pref;
    return (undef, Bivio::TypeError->TOO_LONG)
 	if length($value) > $proto->get_width;
    my($v) = $proto->canonicalize_charset(\$value);
    return length($$v) ? $$v . "\n" : (undef, undef);
}

sub get_width {
    # Max size in browsers
    return 0xffff;
}

1;
