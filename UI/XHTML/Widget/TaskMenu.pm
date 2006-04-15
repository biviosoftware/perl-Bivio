# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TaskMenu;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Bivio::Agent::Request;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_URI) = Bivio::Agent::Request->FORMAT_URI_PARAMETERS;
my($_PARAMS) = [
    'task_id',
    'label',
    @$_URI[1..$#$_URI],
    'control',
    'uri',
];

sub internal_as_string {
    my($self) = @_;
    return map(
	(ref($_) =~ /Link/ ? $_->get('_task_menu_cfg')->{task_id}->get_name
	    : ref($_) eq 'ARRAY' ? $_->[0]
	    : ref($_) eq 'HASH' ? $_->{task_id}
	    : $_),
	@{$self->unsafe_get('task_map') || []},
    );
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	selected_task_name => [['->get_request'], 'task_id', '->get_name'],
	class => 'task_menu',
    );
    $self->initialize_attr('selected_task_name');
    $self->put(
	tag => 'div',
	task_map => [map({
	    my(undef, $cfg) = $self->name_parameters(
		$_PARAMS, ref($_) eq 'ARRAY' ? $_ : [$_]);
	    $cfg->{task_id} = Bivio::Agent::TaskId->from_any($cfg->{task_id});
	    $cfg->{label} ||= $cfg->{task_id}->get_name;
	    $cfg->{uri} ||= URI({
#TODO: Should this default get moved to URI?
		query => undef,
		path_info => undef,
		_cfg($cfg, @$_URI),
	    });
	    $self->initialize_value($cfg->{label}, Link(
		vs_text('task_menu', 'title', $cfg->{label}),
		$cfg->{uri},
		{
		    _task_menu_cfg => $cfg,
		    _cfg($cfg, 'control'),
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
    my($selected) = $self->render_simple_attr('selected_task_name', $source);
    my($need_sep) = 0;
    foreach my $w (@{$self->get('task_map')}) {
	my($cfg) = $w->get('_task_menu_cfg');
	my($r) = $self->render_simple_value($cfg->{realm}, $source);
	next unless $req->can_user_execute_task(
	    $cfg->{task_id},
	    $r || undef,
	);
	my($b) = '';
#TODO: Shouldn't change global state.  Rather put a closure that renders
#       with a value off the request (or lexical value ?)
	$w->put(class => join(' ',
	    $need_sep ? 'want_sep' : (),
	    $cfg->{task_id}->equals_by_name($selected) ? 'selected' : (),
	))->render(
	    $source, \$b,
        );
	next unless $b;
	$need_sep++;
	$$buffer .= $b;
    }
    return;
}

sub _cfg {
    my($cfg) = shift;
    return map(exists($cfg->{$_}) ? ($_ => $cfg->{$_}) : (), @_),
}

1;
