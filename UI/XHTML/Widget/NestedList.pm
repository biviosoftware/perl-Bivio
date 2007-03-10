# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::NestedList;
use strict;
use Bivio::Base 'Bivio::UI::Widget::List';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($c) = $self->unsafe_get('columns');
    $self->die(columns => undef, $c, ': must contain exactly one element')
	unless @$c == 1;
    $self->put(_nested_list => Tag(
 	$self->get_or_default(tag => 'ul'),
 	"\n",
	$self->unsafe_get('class'),
    ));
    $self->put(_nested_list_item => Join([
	Tag(
	    $self->get_or_default('item_tag', 'li'),
	    $c->[0],
	    $self->unsafe_get('item_class'),
	),
	"\n",
    ]));
    $self->put(_nested_list_state => my $state = {});
    $self->put(columns => [[\&_render_item, ['node_level'], $c->[0], $self]]);
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($t) = $self->render_attr('_nested_list', $source);
    my($state) = $self->get('_nested_list_state');
    $$t =~ /^(.+\n)(\S+)$/s;
    %$state = (
	level => -1,
	list_start => $1,
	list_end => $2,
	count => 0,
    );
    shift->SUPER::render(@_);
    _close(-1, $state, $buffer);
    return;
}

sub _close {
    my($to_level, $state, $buffer) = @_;
    while ($state->{level} > $to_level) {
	$$buffer .= $state->{list_end};
	$state->{level}--;
    }
    return;
}

sub _render_item {
    my($source, $node_level, $value, $self) = @_;
    my($state) = $self->get('_nested_list_state');
    $state->{count}++;
    my($b);
    if ($state->{level} < $node_level) {
	$b .= $state->{list_start};
	$state->{level}++;
    }
    else {
	_close($node_level, $state, \$b);
    }
    $self->render_attr('_nested_list_item', $source, \$b);
    return $b;
}

1;
