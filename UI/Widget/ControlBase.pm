# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::ControlBase;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $self->unsafe_render_attr(control_off_value => $source, $buffer);
    return;
}

sub initialize {
    my($self) = @_;
    if (my $c = $self->unsafe_get('control')) {
	unless (ref($c)) {
	    if ($c =~ /^[a-z_0-9]{3,}$/
	        and Bivio::Agent::TaskId->is_valid_name(uc($c))
	    ) {
		Bivio::IO::Alert->warn_deprecated(
		    $c, ': change task name to upper case');
		$c = uc($c);
	    }
	    $c = Bivio::Agent::TaskId->from_name($c)
		if Bivio::Agent::TaskId->is_valid_name($c);
	}
	$self->put(
	    control => [['->get_request'], '->can_user_execute_task', $c],
	) if $self->is_blessed($c, 'Bivio::Agent::TaskId');
    }
    $self->map_invoke(
	unsafe_initialize_attr => [qw(control control_off_value)],
    );
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($c) = $self->unsafe_get('control');
    return !defined($c)
	|| ($c = $self->unsafe_resolve_widget_value($c, $source))
	&& (!$self->is_blessed($c, 'Bivio::UI::Widget')
        || $self->render_simple_value($c, $source))
	? $self->control_on_render($source, $buffer)
	: $self->control_off_render($source, $buffer);
}

1;
