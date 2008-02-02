# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::TextArea;
use strict;
use Bivio::Base 'Type.Text';

# C<Bivio::Type::TextArea> same as L<Bivio::Type::Text|Bivio::Type::Text>
# except 64K characters. This is a typical limit for HTML TEXTAREAs.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LINE_WIDTH {
    return 60;
}

sub from_literal {
    # Wrap text lines at I<line_width> if desired by looking
    # up the user's preference.
    my($proto, $value, $line_width) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    # careful to see if Preferences model is present before accessing
    my($pref);
    if (defined($value)
	    && Bivio::Auth::Support->unsafe_get_user_pref(
		    'TEXTAREA_WRAP_LINES',
		    Bivio::Agent::Request->get_current,
		    \$pref)
	    && $pref) {
	return $proto->wrap_lines($value, $line_width || $proto->LINE_WIDTH);
    }
    return $proto->SUPER::from_literal($value);
}

sub get_width {
    return 64*1024;
}

1;
