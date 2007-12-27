# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Tag;
use strict;
use base 'Bivio::UI::HTML::Widget::ControlBase';
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

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    $self->can('render_tag_value') ? $self->render_tag_value($source, \$b)
	: $self->render_attr('value', $source, \$b);
    return unless length($b)
	|| $self->render_simple_attr('tag_if_empty', $source);
    my($t) = lc(${$self->render_attr('tag')});
    $self->die('tag', $source, $t, ': is not a valid HTML tag')
	unless $t =~ /^[a-z]+\d*$/;
    $b = "\n<!--\n$b\n-->\n"
	if length($b) && $self->render_simple_attr('bracket_value_in_comment');
    my($end) = length($b) || !_empty($t) ? ">$b</$t>" : ' />';
    $self->SUPER::control_on_render($source, \$t);
    $$buffer .= "<$t$end";
    return;
}

sub initialize {
    my($self) = @_;
    unless ($self->unsafe_get('html_attrs')) {
	my($a) = $self->map_each(sub {
            my(undef, $k) = @_;
	    return $k =~ /^[A-Z]+[0-9]?$/ ? $k : ();
	});
	$self->put(html_attrs => vs_html_attrs_merge([sort(@$a)]))
	    if @$a;
    }
    $self->put_unless_exists(tag_if_empty => 1)
	if _empty($self->get('tag'));
    $self->initialize_attr('tag');
    $self->initialize_attr(bracket_value_in_comment => 0);
    $self->unsafe_initialize_attr('value');
    $self->unsafe_initialize_attr('tag_if_empty');
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('tag', 'value');
}

sub internal_new_args {
    my($proto, $tag) = splice(@_, 0, 2);
    return $proto->internal_compute_new_args(
	[qw(tag value)],
	[
	    $tag,
	    (!defined($_[0]) || $_[0] ne '') && _empty($tag) ? '' : (),
	    @_,
	],
    );
}

sub _empty {
    my($tag) = @_;
    return 0
	if ref($tag);
    $tag = lc($tag);
    return grep($tag eq $_, @$_EMPTY) ? 1 : 0;
}

1;
