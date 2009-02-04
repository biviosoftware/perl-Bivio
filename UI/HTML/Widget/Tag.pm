# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Tag;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EMPTY) = [qw(
    area
    base
    basefont
    br
    col
    frame
    hr
    img
    input
    isindex
    link
    meta
    param
)];

sub NEW_ARGS {
    return [qw(tag ?value ?class)];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($buf) = '';
    $self->can('render_tag_value') ? $self->render_tag_value($source, \$buf)
	: $self->render_attr('value', $source, \$buf);
    return unless length($buf)
	|| $self->render_simple_attr('tag_if_empty', $source);
    my($t) = lc(${$self->render_attr('tag', $source)});
    $self->die('tag', $source, $t, ': is not a valid HTML tag')
	unless $t =~ /^[a-z]+\d*$/;
    $buf = "\n<!--\n$buf\n-->\n"
	if length($buf)
	&& $self->render_simple_attr('bracket_value_in_comment', $source);
    my($v) = '';
    $self->internal_tag_render_attrs($source, \$v);
    $$buffer .= "<$t$v"
	. (length($buf) || !_empty($t) ? ">$buf</$t>" : ' />');
    return;
}

sub initialize {
    my($self) = @_;
    my($t, $v) = $self->unsafe_get(qw(tag value));
    if (_empty($t)) {
	if ($v and $v =~ /^[a-z0-9]+$/) {
	    $self->put_unless_exists(class => $v);
	}
	$self->put(value => '');
	$self->put_unless_exists(tag_if_empty => 1);
    }
    elsif (!defined($v)) {
	$self->die('"value" is a required parameter')
	    unless $self->can('render_tag_value');
    }
    elsif (!ref($t) && defined($v) && length($v) == 0) {
	$self->put_unless_exists(tag_if_empty => 1);
    }
    $self->unsafe_initialize_attr('value');
    $self->initialize_attr('tag');
    $self->initialize_attr(bracket_value_in_comment => 0);
    $self->unsafe_initialize_attr('tag_if_empty');
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('tag', 'value');
}

sub internal_tag_render_attrs {
    my($self, $source, $buffer) = @_;
    $self->SUPER::control_on_render($source, $buffer);
    return;
}

sub _empty {
    my($tag) = @_;
    return 0
	if ref($tag);
    $tag = lc($tag);
    return grep($tag eq $_, @$_EMPTY) ? 1 : 0;
}

1;
