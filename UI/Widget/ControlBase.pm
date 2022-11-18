# Copyright (c) 2001-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::ControlBase;
use strict;
use Bivio::Base 'UI.Widget';

my($_TI) = b_use('Agent.TaskId');
my($_A) = b_use('IO.Alert');

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $self->unsafe_render_attr(control_off_value => $source, $buffer);
    return;
}

sub initialize {
    my($self) = @_;
    if (defined(my $c = $self->unsafe_get('control'))) {
        unless (ref($c)) {
            if ($c =~ /^[a-z_0-9]{3,}$/
                and $_TI->is_valid_name(uc($c))
            ) {
                $_A->warn_deprecated(
                    $c, ': change task name to upper case');
                $c = uc($c);
            }
            $c = $_TI->from_name($c)
                if $_TI->is_valid_name($c);
        }
        $self->put(control => [['->req'], '->can_user_execute_task', $c])
            if $_TI->is_blesser_of($c);
    }
    $self->map_invoke(
        unsafe_initialize_attr => [qw(control control_off_value)],
    );
    return shift->SUPER::initialize(@_);
}

sub is_control_on {
    my($self, $source) = @_;
    my($c) = $self->unsafe_get('control');
    return !defined($c)
        || ($c = $self->unsafe_resolve_widget_value($c, $source))
        && (!$self->is_blesser_of($c, 'Bivio::UI::Widget')
        || $self->render_simple_value($c, $source))
        ? 1 : 0;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($method) = $self->is_control_on($source)
        ? 'control_on_render' : 'control_off_render';
    return $self->$method($source, $buffer);
}

1;
