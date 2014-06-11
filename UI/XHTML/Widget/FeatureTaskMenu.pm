# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FeatureTaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget.TaskMenu';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = b_use('Agent.TaskId');
b_use('IO.Config')->register(my $_CFG = {
    use_file_manager => 0,
});

sub NEW_ARGS {
    return [qw(?class)];
}

sub exclude_tasks {
    my($self, $tasks_to_exclude, $tasks) = @_;
    $tasks_to_exclude = {map((lc($_) => 1), @$tasks_to_exclude)};
    return [grep(
	!(ref($_) ? $tasks_to_exclude->{lc($_->{task_id} || '')}
	      : $tasks_to_exclude->{lc($_)}),
	@$tasks,
    )];
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	task_map => $self->internal_tasks,
	want_more_threshold => 4,
	want_sorting => 1,
	selected_item => [sub {
	    my($source) = @_;
	    my($curr_task) = $source->get('task_id')->get_name;
	    $self->do_by_two(
		sub {
		    my($regexp, $task) = @_;
		    return 1
			unless $curr_task =~ $regexp;
		    $curr_task = $task;
		    return 0;
		},
		$self->internal_selected_item_map,
	    );
	    return $_TI->from_name($curr_task);
	}],
    );
    return shift->SUPER::initialize(@_);
}

sub internal_merge_tasks {
    my($self, $parent, $child) = @_;
    my($seen) = {};
    my($labels) = {};
    foreach my $x (@$child) {
	if (my $n = _sort_label($x)) {
	    $labels->{$n}++;
	}
    }
    foreach my $x (@$parent) {
	next
	    unless my $label = _sort_label($x);
	foreach my $n (keys(%$labels)) {
	    $label++
		if $label >= $n;
	}
	$x->{sort_label} = sprintf('sort_label_%02d', $label);
    }
    return [
	map({
	    my($t) = ref($_) ? $_->{task_id} : $_;
	    $t && $seen->{$t}++ ? () : $_;
	} @$child, @$parent),
    ];
}

sub internal_selected_item_map {
    return [
	qr{^FORUM_BLOG_} => 'FORUM_BLOG_LIST',
	qr{^FORUM_CALENDAR_} => 'FORUM_CALENDAR',
	qr{^FORUM_CRM_} => 'FORUM_CRM_THREAD_ROOT_LIST',
	qr{^FORUM_FILE_} => _file_manager_task_id(),
	qr{^FORUM_MAIL_} => 'FORUM_MAIL_THREAD_ROOT_LIST',
	qr{^FORUM_MOTION_} => 'FORUM_MOTION_LIST',
	qr{^FORUM_TUPLE_} => 'FORUM_TUPLE_USE_LIST',
	qr{^FORUM_WIKI_} => 'FORUM_WIKI_VIEW',
	qr{^GROUP_USER_} => 'GROUP_USER_LIST',
    ];
}

sub internal_tasks {
    return [
	map(
	    ref($_) || $_TI->unsafe_from_name($_) ? $_ : (),
	    {
		xlink => vs_text_as_prose('xhtml_site_admin_drop_down_standard')
		    ->put(task_menu_no_wrap => 1),
		label => 'SiteAdminDropDown_label',
		sort_label => 'sort_label_02',
	    },
	    {
		task_id => 'SITE_WIKI_VIEW',
		sort_label => 'sort_label_01',
	    },
	    {
		task_id => 'FORUM_WIKI_VIEW',
		sort_label => 'sort_label_03',
	    },
	    qw(
		FORUM_BLOG_LIST
		FORUM_CALENDAR
	    ),
	    {
		task_id => 'REALM_FEATURE_FORM',
		control =>
		    ['!', [[qw(->req auth_realm)], 'type'], '->eq_forum'],
	    },
	    qw(
		FORUM_EDIT_FORM
	    ),
	    _file_manager_task_id(),
	    qw(
		GROUP_TASK_LOG
		FORUM_MAIL_THREAD_ROOT_LIST
		FORUM_CREATE_FORM
		FORUM_MOTION_LIST
		GROUP_USER_LIST
		FORUM_TUPLE_USE_LIST
		FORUM_CRM_THREAD_ROOT_LIST
	    ),
	),
    ];
}

sub _file_manager_task_id {
    return $_CFG->{use_file_manager}
	? 'FORUM_FILE_MANAGER'
	: 'FORUM_FILE_TREE_LIST';
}

sub _sort_label {
    my($cfg) = @_;
    return $1
	if ref($cfg)
	&& ($cfg->{sort_label} || '') =~ /^sort_label_(\d+)/;
    return undef;
}

1;
