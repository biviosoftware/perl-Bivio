# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::Tag;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

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
    my($self, $source, $wo) = shift->widget_render_args(@_);
    my($buf) = '';
    $self->can('render_tag_value') ? $self->render_tag_value($source, \$buf)
	: $self->render_attr('value', $source, \$buf);
    $buf = $self->render_simple_attr(tag_empty_value => $source)
	unless length($buf);
    return unless length($buf)
	|| $self->render_simple_attr('tag_if_empty', $source);
    my($t) = lc(${$self->render_attr('tag', $source)});
    $self->die('tag', $source, $t, ': is not a valid HTML tag')
	unless $t =~ /^([a-z\d]+:)?[a-z]+\d*$/;
    my($pre, $post) = $buf !~ qr{\w} ? ('', '')
        : $self->render_simple_attr('bracket_value_in_comment', $source)
        ? ("\n<!--\n", "\n-->\n")
        : map($self->render_simple_attr($_, $source),
              'tag_pre_value',
              'tag_post_value',
          );
    my($v) = '';
    $self->internal_tag_render_attrs($source, \$v);
    $wo->append_buffer(
	"<$t$v",
	(length($buf) || !_empty($t) ? ('>', \$pre, \$buf, \$post, "</$t>") : ' />'),
    );
    if ($self->unsafe_get('class')) {
	foreach my $class (
	    split(' ', $self->render_simple_attr('class', $source))) {
	    _add_to_view_css($self, $class, $source);
	}
    }
    return;
}

sub initialize {
    my($self, $source) = @_;
    my($t, $v) = $self->unsafe_get(qw(tag value));
    $self->die('missing tag')
	unless $t;

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
    $self->unsafe_initialize_attr('value', $source);
    $self->initialize_attr('tag', undef, $source);
    $self->die(
        'bracket_value_in_comment',
        undef,
        'cannot specify with either tag_pre_value or tag_post_value',
    ) if $self->has_keys('tag_pre_value')
        || $self->has_keys('tag_post_value')
        and $self->has_keys('bracket_value_in_comment');
    $self->initialize_attr(bracket_value_in_comment => 0, $source);
    $self->map_invoke(unsafe_initialize_attr => [qw(
	tag_pre_value
	tag_post_value
	tag_if_empty
	tag_empty_value
        tag_post_value
    )], undef, [$source]);
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

sub _add_to_view_css {
    my($self, $class, $source) = @_;
    my($path) = [join('.', $self->get('tag'), $class)];
    my($current) = $self->unsafe_get('parent');

    while ($current) {
	if ($current->isa('Bivio::UI::HTML::Widget::Tag')
		|| $current->isa('Bivio::UI::HTML::Widget::TableBase')) {
	    my($tag) = $current->unsafe_get('tag') || '';
#TODO: can't render complex values using render_simple_attr()
# because we don't know which source was used to render the value	    
	    my($class) = $current->unsafe_get('class')
		&& ! ref($current->get('class'))
		? split(' ', $current->get('class'))
		: '';
	    my($id) = $tag . ($class ? ".$class" : '');
	    unshift(@$path, $id)
		if $id;
	}
	$current = $current->unsafe_get('parent');
    }
    b_use('View.CSS')->add_to_css($self, join(' ', @$path), $class, $source);
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
