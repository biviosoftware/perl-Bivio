# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Line;
use strict;
use Bivio::Base 'Type.String';

# C<Bivio::Type::Line> defines a compound name or long line of text, e.g.
# a person's full name, an e-mail address, and an account name.
# If you want
# a simple name, e.g.
# first name, use L<Bivio::Type::Name|Bivio::Type::Name>.
#
# Note: leading and trailing spaces are trimmed in
# L<from_literal|"from_literal">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    # (proto, string) : any
    # Returns C<undef> if the line is empty.
    # Leading and trailing blanks are trimmed.
    # Length is checked.
    my($proto, $value) = @_;
    # Leave middle spaces in case a "display" name.
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    return $proto->SUPER::from_literal($value);
}

sub get_width {
    # : int
    # Returns 100.
    return 100;
}

1;
