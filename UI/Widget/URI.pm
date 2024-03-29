# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::URI;
use strict;
use Bivio::Base 'Widget.ControlBase';


sub initialize {
    my($self) = @_;
    my($h) = $self->get('format_uri_hash');
    $self->put(control => delete($h->{control}))
        if exists($h->{control});
    $h->{query} ||= undef;
    $h->{path_info} ||= undef;
    $self->initialize_attr(format_method => 'format_uri');
    while (my($k, $v) = each(%$h)) {
        $self->initialize_value("format_uri_hash.$k", $v);
    }
    return shift->SUPER::initialize(@_);
}

sub new {
    my($proto, $format_uri_hash, $attrs) = @_;
    return shift->SUPER::new(@_)
        unless $format_uri_hash && ref($format_uri_hash) eq 'HASH';
    $attrs ||= ref($format_uri_hash) eq 'HASH'
        && ref($format_uri_hash->{format_uri_hash}) eq 'HASH'
        ? $format_uri_hash : {};
    $attrs->{format_uri_hash} ||= $format_uri_hash;
    $attrs->{format_method}
        ||= delete($attrs->{format_uri_hash}->{format_method})
        || 'format_uri';
    return $proto->SUPER::new($attrs);
}

sub internal_new_args {
    my(undef, $task_id) = @_;
    return {
        format_uri_hash => {
            task_id => Bivio::Agent::TaskId->from_any($task_id),
        },
    };
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($method) = $self->render_simple_attr('format_method', $source);

    if ($self->get('format_uri_hash')->{query_type}) {
        $$buffer .= $source->$method(
            $self->get('format_uri_hash')->{query_type},
            $self->get('format_uri_hash')->{task_id},
        );
    }
    else {
        $$buffer .= $source->req->$method(_render_hash(
            $self, 'format_uri_hash', $self->get('format_uri_hash'), $source));
    }
    return;
}

sub _render_hash {
    my($self, $name, $hash, $source) = @_;
    my($b);
    return {map(
        ($_ => ref($hash->{$_}) eq 'HASH'
             ? _render_hash($self, "$name.$_", $hash->{$_}, $source)
             : _render_value($self, $_, $hash->{$_}, $source)),
        keys(%$hash),
    )};
}

sub _render_value {
    my($self, $name, $value, $source) = @_;
    return $value
        if UNIVERSAL::isa($value, 'Bivio::Agent::TaskId');
    my($v) = $self->unsafe_resolve_widget_value($value, $source);
    return $v
        if !ref($v) || ref($v) eq 'HASH';
    my($b) = '';
    return $self->unsafe_render_value($name, $value, $source, \$b)
        ? $b : undef;
}

1;
