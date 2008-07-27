# Copyright (c) 2003-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Tables::Cell;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub as_string {
    my($self) = @_;
    return $self->has_keys('text')
	? $self->get('text')
	: ref($self)
	? undef
	: $self;
}

1;
