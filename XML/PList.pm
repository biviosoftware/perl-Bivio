# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::XML::PList;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::File;
use XML::Parser ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub to_tree {
    my(undef, $xml) = @_;
    $xml = Bivio::IO::File->read($xml)
	unless ref($xml);
    return _from_xhtml_children(
	XML::Parser->new(Style => 'Tree')->parse($$xml),
    )->[0]->[0];
}

sub _from_xhtml_children {
    my($children) = @_;
    return [map(
	_from_xhtml_child($children->[$_ *= 2], $children->[++$_]),
	0 .. @$children/2 - 1,
    )];
}

sub _from_xhtml_child {
    my($tag, $children) = @_;
    return $children =~ /\S/ ? $children : ()
	unless $tag;
    shift(@$children)
	if ref($children->[0]) eq 'HASH';
    return _from_xhtml_children($children)
	if $tag =~ /^(?:plist|array)$/;
    unless ($tag eq 'dict') {
	my($res) = _from_xhtml_children($children);
	return @$res ? @$res : '';
    }
    return {@{_from_xhtml_children($children)}};
}

1;
