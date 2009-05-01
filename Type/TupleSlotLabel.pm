# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::TupleSlotLabel;
use strict;
use Bivio::Base 'Type.TupleLabel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CHAR) = qr{[-\w]};
my($_REGEX) = qr{[A-Z](?:$_CHAR)+}o;

sub REGEX {
    return $_REGEX;
}

sub VALID_CHAR_REGEX {
    return $_CHAR;
}

1;
