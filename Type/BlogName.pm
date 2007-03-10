# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogName;
use strict;
use base 'Bivio::Type::FileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

sub ERROR {
    return Bivio::TypeError->BLOG_NAME;
}

sub REGEX {
    return qr{[A-Z0-9a-z0-9 ]+};
}

sub absolute_path {
    my(undef, $value) = @_;
    return $_FP->from_literal_or_die('/Blog/' . $value);
}

sub to_absolute {
    return shift->absolute_path(@_);
}

1;
