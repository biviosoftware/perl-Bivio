# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Director;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Die;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = __PACKAGE__->use('Type.Regexp');

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
    my($values) = $self->get('values');
    $self->put(_value_array => [map({
	my($k) = $_;
	my($r) = $k =~ /^\(\?.+\)$/s ? $_R->from_literal($k) : ();
	($r || $k => $self->initialize_value($k, $values->{$_}));
    } sort(keys(%$values)))]);
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
	my($x) = $self->map_by_two(
	    sub {
		my($k, $v) = @_;
		return
		    unless (ref($k) ? $ctl =~ $k : $k eq $ctl) && defined($v);
		return ($v || undef, $k);
	    },
	    $self->get('_value_array'),
	);
	if (@$x) {
	    Bivio::Die->die($x, ': control matches too many keys')
	        if @$x > 2;
	    return @$x;
	}
	$n = 'default_value';
    }
    my($v) = $self->unsafe_get($n);
    return ($v || undef, $n)
	if defined($v);
    Bivio::Die->die(
	$self->get('control'), '=', $ctl,
	": control matches $n value, but not specified");
    # DOES NOT RETURN
}

1;
