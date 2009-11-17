# Copyright (c) 2000-2009 bivio Software, Inc.  All rights reserved.
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

sub canonicalize_newlines {
    my(undef, $value) = @_;
    my($v) = ref($value) ? $value : \$value;
    $$v =~ s/\r\n|\n\r|\r/\n/sg;
    $$v =~ s/^\s+$//mg;
    $$v =~ s/^\n+|\n+$//sg;
    $$v =~ s/\n{3,}/\n\n/sg;
    $$v .= "\n"
	if length($$v);
    return $v;
}

sub from_literal {
    # Wrap text lines at I<line_width> if desired by looking
    # up the user's preference.
    my($proto, $value, $line_width) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
 	unless defined($value) && length($value);
    # careful to see if Preferences model is present before accessing
    my($pref, $req);
    return $proto->wrap_lines($value, $line_width || $proto->LINE_WIDTH)
	if defined($value)
        and $req = Bivio::Agent::Request->get_current
	and Bivio::Auth::Support
	    ->unsafe_get_user_pref('TEXTAREA_WRAP_LINES', $req, \$pref)
        and $pref;
    return (undef, Bivio::TypeError->TOO_LONG)
 	if length($value) > $proto->get_width;
    $proto->canonicalize_newlines(\$value);
    return $value =~ /\S/ ? $value : (undef, undef);
}

sub get_width {
    # Max size in browsers
    return 0xffff;
}

1;
