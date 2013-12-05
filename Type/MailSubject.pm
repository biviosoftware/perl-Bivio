# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailSubject;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_W) = b_use('MIME.Word');

sub CLEAN_REGEX {
    return qr{\s$|/|@{[shift->get_instance('FilePath')->ILLEGAL_CHAR_REGEXP]}}o;
}

sub EMPTY_VALUE {
    return '(No Subject)';
}

sub clean_and_trim {
    my($proto, $value, $extra_clean) = @_;
    if ($value && $value =~ /\=\?[A-Z0-9\-]+\?/i) {
	$value = ${$proto->canonicalize_charset($_W->decode($value) || '')};
    }
    $value = ''
	unless defined($value);
    $value =~ s/\s+/ /;
    0 while $value =~ s/^(\s+|\[\S*\]|[a-z]{1,3}(:|\[\d+\])|\.)//i;
    $value =~ s{@{[$proto->CLEAN_REGEX]}}{}g
	if $extra_clean;
    $value = length($value)
	? $value
	: $proto->EMPTY_VALUE;
    return $proto->SUPER::clean_and_trim($value);
}

1;
