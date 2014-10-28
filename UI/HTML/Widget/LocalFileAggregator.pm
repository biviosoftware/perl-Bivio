# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::LocalFileAggregator;
use strict;
use Bivio::Base 'UI.Widget';
b_use('UI.ViewLanguageAUTOLOAD');

my($_VALUE_ATTRS) = [qw(base_values widget_values view_values)];

sub NEW_ARGS {
    return [map("?$_", @$_VALUE_ATTRS)];
}

sub initialize {
    my($self, $source) = @_;
    _do(
	$self,
	sub {
	    my($value, $name, $attr) = @_;
	    $self->initialize_value($name, $value, $source);
	    return;
	},
    );
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($type);
    my($rendered) = $source->req->get_if_exists_else_put($self->package_name, {});
#TODO: Verify all types in an instance are the same
    my($final_render);
    _do(
	$self,
	sub {
	    my($value, $name, $attr) = @_;
	    my($b);
	    $self->unsafe_render_value($name, $value, $source, \$b);
	    return
		unless $b;
	    $type = _type($b);
	    $final_render = $type
		if $attr eq $_VALUE_ATTRS->[0];
	    push(@{($rendered->{$type} ||= {})->{$attr} ||= []}, $b)
		if $b;
	    return;
	},
    );
    _render($self, delete($rendered->{$final_render}), $source, $buffer)
	if $final_render;
    return;
}

sub _do {
    my($self, $op, $rendered) = @_;
    foreach my $attr (@$_VALUE_ATTRS) {
	my($i) = 0;
	foreach my $v (@{
	    ($rendered && $rendered->{$attr} || $self->unsafe_get($attr)) || [],
	}) {
	    $op->($v, $attr . $i++, $attr);
	}
    }
    return;
}

sub _is_inline {
    my($value) = @_;
    return $value =~ m{[\n<]};
}

sub _render {
    my($self, $rendered, $source, $buffer) = @_;
    my($seen) = {};
    _do(
	$self,
	sub {
	    my($value, $name, $attr) = @_;
	    return
		unless $value;
	    _render_value($self, $value, $source, $buffer)
		unless $seen->{$value}++;
	    return;
	},
	$rendered,
    );
    return;
}

sub _render_value {
    my($self, $value, $source, $buffer) = @_;
    if (_is_inline($value)) {
	$$buffer .= $value;
    }
    else {
	HTMLWidget_LocalFileLink($value)->initialize_and_render($source, $buffer)
    }
    return;
}

sub _type {
    my($value) = @_;
    return _is_inline($value)
	? $value =~ m{type=.*?(text/(?:javascript|css))}s
	? $1
	: b_die($value, ': must be text/javascript or text/css')
	: HTMLWidget_LocalFileLink()->to_html_type_attr($value);
}

1;
