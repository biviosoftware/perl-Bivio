# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::URI;
use strict;
use base 'Bivio::UI::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub intitialize {
    my($self) = @_;
    my($h) = $self->get('format_uri_hash');
    while (my($k, $v) = each(%$h)) {
	$self->initialize_value("format_uri_hash.$k", $v);
    }
    return;
}

sub new {
    my($proto, $format_uri_hash, $attrs) = @_;
    $attrs ||= ref($format_uri_hash) eq 'HASH'
	&& ref($format_uri_hash->{format_uri_hash}) eq 'HASH'
	? $format_uri_hash : {};
    $attrs->{format_uri_hash} ||= $format_uri_hash;
    Bivio::Die->die(
	$format_uri_hash, '"format_uri_args" attribute must be a hash_ref'
    ) unless ref($attrs->{format_uri_hash}) eq 'HASH';
    return $proto->SUPER::new($attrs);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($method) = $self->render_simple_attr('format_method') || 'format_uri';
    $$buffer .= $source->get_request->$method(
	_render_hash(
	    $self, 'format_uri_hash', $self->get('format_uri_hash'), $source));
    return;
}

sub _render_hash {
    my($self, $name, $hash, $source) = @_;
    my($b);
    return {map(
	($_ => ref($hash->{$_}) eq 'HASH'
	     ? _render_hash($self, "$name.$_", $hash->{$_}, $source)
	     : $self->unsafe_render_value(
		 "$name.$_",
		 $hash->{$_},
		 $source,
		 ($b = '', \$b)[1]
	     ) ? $b : undef),
	keys(%$hash),
    )};
}

1;
