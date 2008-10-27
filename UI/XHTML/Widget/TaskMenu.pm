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
    @$_URI[1..$#$_URI],
    'control',
    'uri',
    'xlink',
];

sub internal_as_string {
    my($self) = @_;
    return map(
	(ref($_) =~ /Link/ ?
	    $_->get('_task_menu_cfg')->{xlink}
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
    );
    $self->initialize_attr('selected_item');
    my($prefix) = $self->unsafe_initialize_attr('selected_label_prefix');
    my($need_sep, $selected);
    my($i);
    $self->put(
	tag => 'div',
	value => '',
	_init => sub {
	    my($source) = @_;
	    $need_sep = 0;
	    $selected = $self->resolve_attr('selected_item', $source);
	    return \$need_sep;
	},
	task_map => [map({
	    my(undef, $cfg) = $self->name_parameters(
		$_PARAMS, ref($_) eq 'ARRAY' ? $_
		    : [$self->is_blessed($_, 'Bivio::UI::Widget') ? {
			xlink => $_,
		    } : $_],
	    );
	    if ($cfg->{task_id}) {
		$cfg->{task_id}
		    = Bivio::Agent::TaskId->from_any($cfg->{task_id});
		$cfg->{label} ||= $cfg->{task_id}->get_name;
		$cfg->{uri} ||= URI({
		    _cfg($cfg, @$_URI),
		});
	    }
            my($selected_cond) = ['->req', _selected_attr($self, \$i)];
 	    my($w) = $self->is_blessed($cfg->{xlink}, 'Bivio::UI::Widget')
		? $cfg->{xlink}
		: $cfg->{xlink} ? XLink($cfg->{xlink})
		: $cfg->{task_id} ? Link(
                    _prefix(
                        $prefix,
                        ref($cfg->{label}) ? $cfg->{label}
                            : vs_text('task_menu', 'title', $cfg->{label}),
                        $selected_cond,
                    ),
		    $cfg->{uri}
	        ) : $self->die(
		    [qw(xlink task_id)], undef, 'missing task_id or xlink');
	    my($class) = $w->unsafe_get('class');
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

sub internal_new_args {
    return shift->internal_compute_new_args([qw(task_map ?class)], \@_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    my($req) = $self->get_request;
    my($need_sep) = $self->get('_init')->($source);
    my($i);
    foreach my $w (@{$self->get('task_map')}) {
        my($selected_attr) = _selected_attr($self, \$i);
	next
	    if $w->can('is_control_on') && !$w->is_control_on($source);
        $req->put($selected_attr =>
                      $w->render_simple_attr('_is_selected', $source));
	my($cfg) = $w->get('_task_menu_cfg');
	my($r) = $self->render_simple_value($cfg->{realm}, $source);
	next unless !$cfg->{task_id} || $req->can_user_execute_task(
	    $cfg->{task_id},
	    $r || undef,
	);
	my($b) = '';
	$w->render($source, \$b);
	next unless $b;
	$$need_sep++;
	$$buffer .= $b;
    }
    return;
}

sub _cfg {
    my($cfg) = shift;
    return map(exists($cfg->{$_}) ? ($_ => $cfg->{$_}) : (), @_),
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

sub _selected_attr {
    my($self, $i) = @_;
    $$i = 0
        unless defined($$i);
    my($res) = "$self.$$i.is_selected";
    ++$$i;
    return $res;
}

1;
