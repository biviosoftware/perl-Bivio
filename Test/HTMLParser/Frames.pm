# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Frames;
use strict;
use Bivio::Base 'Bivio::Test::HTMLParser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->register(['Cleaner']);

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    return unless $tag eq 'frame';
    $self->get('elements')->{$attr->{name} || _anon($self)} = {%$attr};
    return;
}

sub _anon {
    my($self) = @_;
    my($i) = 0;
    my($e) = $self->get('elements');
    my($l);
    $i++
	while $e->{$l = '_anon#' . $i};
    return $l;
}

1;
