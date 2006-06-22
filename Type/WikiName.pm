# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiName;
use strict;
use base 'Bivio::Type::FileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');
my($_ABSOLUTE_PATH) = qr{^(?i:/Wiki/)@{[__PACKAGE__->REGEX]}$};

sub REGEX {
    return qr{[A-Z][A-Z0-9]*[a-z][a-z0-9]*[A-Z][A-za-z0-9]*};
}

sub absolute_path {
    my(undef, $value) = @_;
    return $_FP->from_literal_or_die('/Wiki/' . $value);
}

sub from_literal {
    my($proto) = shift;
    my($v, $e) = $proto->SUPER::from_literal(@_);
    return ($v, $e)
	unless defined($v);
    $v =~ s/\s+//g;
    return $v =~ qr{^@{[$proto->REGEX]}$}o
	? $v : (undef, Bivio::TypeError->WIKI_NAME);
}

sub is_absolute_path {
    my($proto, $path) = @_;
    return $path =~ $_ABSOLUTE_PATH ? 1 : 0;
}

1;
