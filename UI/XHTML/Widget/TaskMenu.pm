# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TaskMenu;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	task_name => [['->get_request'], 'task_id', '->get_name'],
	class => 'task_menu',
    );
    $self->initialize_attr('task_name');
    $self->put(
	tag => 'div',
	task_map => [map({
	    my($task, $href, $label, $control) = ref($_) ? @$_ : $_;
	    $task = Bivio::Agent::TaskId->$task();
	    $self->initialize_value($task->get_name, Link(
		vs_text('task_menu', 'title', $label || $task->get_name),
		$href || $task,
		{
		    _task_menu_task_id => $task,
		    $control ? (control => $control) : (),
		},
	    ));
	} @{$self->get('task_map')})],
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(task_map)], \@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $self->get_request;
    my($selected) = $self->render_simple_attr('task_name', $source);
    my($need_sep) = 0;
    foreach my $w (@{$self->get('task_map')}) {
	my($t) = $w->get('_task_menu_task_id');
	next unless $req->can_user_execute_task($t);
	my($b) = '';
#TODO: Shouldn't change global state.  Rather put a closure that renders
#       with a value off the request (or lexical value ?)
	$w->put(class => join(' ',
	    $need_sep ? 'want_sep' : (),
	    $t->equals_by_name($selected) ? 'selected' : (),
	))->render(
	    $source, \$b,
        );
	next unless $b;
	$need_sep++;
	$$buffer .= $b;
    }
    return;
}

1;
