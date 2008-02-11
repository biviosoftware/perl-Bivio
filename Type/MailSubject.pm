# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailSubject;
use strict;
use base 'Bivio::Type::Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CLEAN_REGEX {
    return qr{\s$|/|@{[shift->get_instance('FilePath')->ILLEGAL_CHAR_REGEXP]}}o;
}

sub EMPTY_VALUE {
    return '(No Subject)';
}

sub clean_and_trim {
    return lc(shift->trim_literal($_[0], 1));
}

sub trim_literal {
    my($proto, $value, $clean) = @_;
    $value = ''
	unless defined($value);
    $value =~ s/\s+/ /;
    0 while $value =~ s/^(\s+|\[\S*\]|[a-z]{1,3}(:|\[\d+\])|\.)//i;
    $value =~ s{@{[$proto->CLEAN_REGEX]}}{}g
	if $clean;
    return length($value) ? substr($value, 0, $proto->get_width)
	: $proto->EMPTY_VALUE;
}

1;
