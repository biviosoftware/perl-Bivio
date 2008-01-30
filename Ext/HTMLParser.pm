# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::HTMLParser;
use strict;
use base 'HTML::Parser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PACKAGE) = __PACKAGE__;

sub comment {
    return _client(@_);
}

sub end {
    return _client(@_);
}

sub new {
    my(undef, $client) = @_;
    my($self) = shift->SUPER::new;
    $self->{$_PACKAGE} = {
	client => $client,
    };
    return $self;
}

sub start {
    return _client(@_);
}

sub text {
    return _client(@_);
}

sub _client {
    my($self) = shift;
    my($method) = 'html_parser_' . Bivio::UNIVERSAL->my_caller;
    return $self->{$_PACKAGE}->{client}->$method(@_);
}

1;
