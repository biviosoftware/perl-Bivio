# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Director;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Die;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    my($w) = _select($self, $req);
    Bivio::Die->die('Director did not select a widget; no content type')
        unless defined($w);
    return $w->execute($req);
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('control');
    $self->unsafe_initialize_attr('default_value');
    $self->unsafe_initialize_attr('undef_value');
    while (my($k, $v) = each(%{$self->get('values')})) {
	$self->initialize_value($k, $v);
    }
    return;
}

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('control');
}

sub internal_new_args {
    my(undef, $control, $values, $default_value, $undef_value, $attrs) = @_;
    return '"control" attribute must be defined' unless defined($control);
    return {
	control => $control,
	values => $values ? $values : {},
	default_value => $default_value,
	undef_value => $undef_value,
	($attrs ? %$attrs : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($v, $n) = _select($self, $source);
    $self->unsafe_render_value($n, $v, $source, $buffer)
	if defined($v);
    return;
}

sub _select {
    my($self, $source) = @_;
    my($ctl) = '';
    my($n) = 'undef_value';
    if ($self->unsafe_render_attr('control', $source, \$ctl)) {
	my($values) = $self->get('values');
	return ($values->{$ctl} || undef, $ctl)
	    if defined($values->{$ctl});
	$n = 'default_value';
    }
    my($v) = $self->unsafe_get($n);
    return ($v || undef, $n)
	if defined($v);
    Bivio::Die->die($self->get('control'), ': invalid control value: ', $ctl);
    # DOES NOT RETURN
}

1;
