# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Text::Widget::Link;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_W) = b_use('UI.Widget');
my($_TI) = b_use('Agent.TaskId');

sub NEW_ARGS {
    return [qw(value)];
}

sub initialize {
    my($self) = @_;
    $self->put(value => _initialize_value($self));
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($v) = $self->render_attr('value', $source);
    $$buffer .= $self->req->format_http({
	uri => $$v,
	carry_query => 0,
	carry_path_info => 0,
    });
    return;
}

sub _initialize_value {
    my($self) = @_;
    my($v) = $self->initialize_attr('value');
    return [['->req'], '->format_stateless_uri', $_TI->from_any($v)]
	if $_TI->is_blessed($v) || $_TI->is_valid_name($v);
    return $v;
}

1;
