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
    my($dup) = {};
    $self->put(
	tag => 'div',
	task_map => [map({
	    my($t, $h) = ref($_) ? @$_ : $_;
	    $t = Bivio::Agent::TaskId->$t();
	    Bivio::Die->die($t, ': duplicate task')
	        if $dup->{$t}++;
	    $self->initialize_value($t->get_name, Link(
		vs_text('title', $t->get_name),
		$h || $t,
		{_task_menu_task_id => $t},
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
	$w->put(class => join(' ',
	    $need_sep++ ? 'want_sep' : (),
	    $t->equals_by_name($selected) ? 'selected' : (),
	))->render(
	    $source, $buffer
        ) if $req->can_user_execute_task($t);
    }
    return;
}

1;
