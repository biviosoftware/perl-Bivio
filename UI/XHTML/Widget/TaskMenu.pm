# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::TaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_URI) = b_use('Agent.Request')->FORMAT_URI_PARAMETERS;
my($_PARAMS) = [
    'task_id',
    'label',
    grep($_ ne 'task_id', @$_URI),
    'control',
    'uri',
    'xlink',
    'sort_label',
];
my($_W) = b_use('UI.Widget');
my($_CB) = b_use('HTMLWidget.ControlBase');
my($_TI) = b_use('Agent.TaskId');
my($_A) = b_use('Type.Array');
my($_DEFAULT_WANT_MORE_THRESHOLD) = 5;

sub NEW_ARGS {
    return [qw(task_map ?class)];
}

sub internal_as_string {
    my($self) = @_;
    return map(
	(ref($_) =~ /Link/ && $_->unsafe_get('_task_menu_cfg')
	    ? $_->get('_task_menu_cfg')->{xlink}
	    || $_->get('_task_menu_cfg')->{task_id}->get_name
	    : ref($_) eq 'ARRAY' ? $_->[0]
	    : ref($_) eq 'HASH' ?  $_->{xlink} || $_->{task_id}
	    : $_),
	@{$self->unsafe_get('task_map') || []},
    );
}

sub initialize {
    my($self) = @_;
    return
        if $self->unsafe_get('_init');
    $self->put_unless_exists(
	selected_item => [['->get_request'], 'task_id'],
	class => 'task_menu',
	tag_if_empty => 0,
	tag => 'div',
	show_current_task => 1,
    );
    $self->initialize_attr('selected_item');
    $self->unsafe_initialize_attr('want_more');
    $self->unsafe_initialize_attr('want_more_threshold');
    $self->initialize_attr(want_sorting => 0);
    my($prefix) = $self->unsafe_initialize_attr('selected_label_prefix');
    my($need_sep, $selected);
    $self->put(
	_init => sub {
	    my($source) = @_;
	    $need_sep = 0;
	    $selected = $self->resolve_attr('selected_item', $source);
	    return \$need_sep;
	},
	task_map => [map({
	    my(undef, $cfg) = $self->name_parameters(
		$_PARAMS, ref($_) eq 'ARRAY' ? $_
		    : [$_W->is_blessed($_) ? {xlink => $_}
		    : $_],
	    );
	    if ($cfg->{task_id}) {
		unless (ref($cfg->{task_id})) {
		    if ($cfg->{task_id} =~ /^[a-z\.\d_]+$/) {
			$cfg->{xlink} = delete($cfg->{task_id});
		    }
		    else {
			$cfg->{task_id} = $_TI->from_any($cfg->{task_id});
		    }
		}
		if (ref($cfg->{task_id})) {
		    $cfg->{label} ||= $cfg->{task_id}->get_name;
		    $cfg->{uri} ||= URI({
			_cfg($cfg, @$_URI),
		    });
		}
	    }
	    $self->initialize_value(
		'sort_label',
		$cfg->{sort_label} = _label($cfg->{sort_label}),
	    ) if $cfg->{sort_label} ||= $cfg->{label};
            my($selected_cond) = ['->ureq', _selected_attr($self, $cfg)];
 	    my($w) = $_W->is_blessed($cfg->{xlink})
		? $cfg->{xlink}
		: $cfg->{xlink} ? XLink($cfg->{xlink})
		: $cfg->{task_id} ? Link(
                    _prefix(
                        $prefix,
                        ref($cfg->{label}) ? $cfg->{label}
                            : _label($cfg->{label}),
                        $selected_cond,
                    ),
		    $cfg->{uri},
	        ) : $self->die(
		    [qw(xlink task_id)], undef, 'missing task_id or xlink');
	    $w = DIV_task_menu_wrapper($w)
		if $cfg->{xlink} && !$_CB->is_blessed($w);
	    my($class) = $w->unsafe_get('class');
	    $self->initialize_value('label', $cfg->{label});
	    $w->put(
		_task_menu_cfg => $cfg,
		_cfg($cfg, 'control'),
                _is_selected => [sub {
                    my($source) = @_;
                    return (ref($selected) eq 'CODE'
                        ? $selected->($w, $source)
                        : ref($selected) eq 'Regexp'
                        ? ($source->ureq('uri') || '') =~ $selected
                        : $cfg->{task_id} && ref($selected)
			? $cfg->{task_id} == $selected
			: $selected eq $w->render_simple_attr(value => $source)
                    ) ? 1 : 0;
                }],
		class => Join([
		    defined($class) ? $class : (),
		    [sub {$need_sep ? 'want_sep' : ()}],
                    If($selected_cond, 'selected'),
		], {join_separator => ' '}),
	    );
	    $self->initialize_value($cfg->{label}, $w);
	} @{$self->get('task_map')})],
    );
    return shift->SUPER::initialize(@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $self->get_request;
    my($need_sep) = $self->get('_init')->($source);
    my($buffers) = [];
    my($sct) = $self->render_simple_attr(show_current_task => $source);
    foreach my $w (_render_list($self, $source)) {
	my($cfg) = $w->get('_task_menu_cfg');
	next
	    if !$sct && $cfg->{task_id}
	    && $req->get('task_id')->equals($cfg->{task_id});
        my($selected_attr) = _selected_attr($self, $cfg);
	next
	    if $w->can('is_control_on') && !$w->is_control_on($source);
        $req->put(
	    $selected_attr => $w->render_simple_attr('_is_selected', $source));
	my($r) = $self->render_simple_value($cfg->{realm}, $source);
	next unless !$cfg->{task_id} || $req->can_user_execute_task(
	    $cfg->{task_id},
	    $r || undef,
	);
	my($b) = '';
	$w->render($source, \$b);
	next
	    unless $b;
	$$need_sep++;
        push(@$buffers, $b);
    }
    _want_more($self, $source, $buffers);
    $$buffer .= join('', @$buffers);
    return;
}

sub _cfg {
    my($cfg) = shift;
    return map(exists($cfg->{$_}) ? ($_ => $cfg->{$_}) : (), @_),
}

sub _label {
    my($label) = @_;
    return Prose(vs_text('task_menu', 'title', $label));
}

sub _prefix {
    my($prefix, $label, $cond) = @_;
    return $label
        unless $prefix;
    return Join([
        If($cond, $prefix),
        $label,
    ]);
}

sub _render_list {
    my($self, $source) = @_;
    my($list) = $self->get('task_map');
    return @$list
	unless $self->render_simple_attr('want_sorting', $source);
    return @{$_A->map_sort_map(
	sub {
	    my($cfg) = shift->get('_task_menu_cfg');
	    return lc($self->render_simple_value(
		$cfg->{sort_label},
		$source,
	    ));
	},
	sub {shift cmp shift},
	$list,
    )};
}

sub _selected_attr {
    my($self, $cfg) = @_;
    return "$self.$cfg.is_selected";
}

sub _want_more {
    my($self, $source, $buffers) = @_;
    return
	unless $self->render_simple_attr('want_more', $source)
	or my $wmc = $self->render_simple_attr('want_more_threshold', $source);
    return
	unless @$buffers > 1 + ($wmc ||= $_DEFAULT_WANT_MORE_THRESHOLD);
    my($b) = '';
    DIV(
	DropDown(
	    String('more'),
	    DIV_dd_menu(
		Join([splice(@$buffers, $wmc)]),
	    ),
	),
	{class => 'task_menu_wrapper want_sep'},
    )->initialize_and_render($source, \$b);
    push(@$buffers, $b);
    return;
}

1;
