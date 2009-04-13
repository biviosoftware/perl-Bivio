# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::XML;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MAP) = {
    '<' => 'lt',
    '>' => 'gt',
    '"' => 'quot',
    "'" => 'apos',
    '&' => 'amp',
};
my($_CHARS) = join('\\', '', sort(keys(%$_MAP)));

sub escape {
    my(undef, $value) = @_;
    return ''
	unless defined($value);
    $value =~ s{([$_CHARS])}{&$_MAP->{$1};}osg;
    return $value;
}

1;
