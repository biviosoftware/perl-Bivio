# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::BlogName;
use strict;
use base 'Bivio::Type::FileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

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

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    return $v =~ qr{^@{[$proto->REGEX]}$}o
	? $v : (undef, Bivio::TypeError->BLOG_NAME);
}

1;
