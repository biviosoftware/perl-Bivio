# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FeatureTaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget.TaskMenu';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(?class)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	task_map => $self->internal_tasks,
	want_more_threshold => 4,
	selected_item => sub {sub {
	    my(undef, $source) = @_;
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
	    return $curr_task;
	}},
    );
    return shift->SUPER::initialize(@_);
}

sub internal_selected_item_map {
    return [
	qr{^FORUM_BLOG_} => 'FORUM_BLOG_LIST',
	qr{^FORUM_CALENDAR_} => 'FORUM_CALENDAR',
	qr{^FORUM_CRM_} => 'FORUM_CRM_THREAD_ROOT_LIST',
	qr{^FORUM_FILE_} => 'FORUM_FILE_TREE_LIST',
	qr{^FORUM_MAIL_} => 'FORUM_MAIL_THREAD_ROOT_LIST',
	qr{^FORUM_MOTION_} => 'FORUM_MOTION_LIST',
	qr{^FORUM_TUPLE_} => 'FORUM_TUPLE_USE_LIST',
	qr{^FORUM_WIKI_} => 'FORUM_WIKI_VIEW',
	qr{^GROUP_USER_} => 'GROUP_USER_LIST',
    ];
}

sub internal_tasks {
    return [
	vs_text_as_prose('xhtml_site_admin_drop_down_standard'),
	qw(
	    SITE_WIKI_VIEW
	    FORUM_BLOG_LIST
	    FORUM_WIKI_VIEW
	    FORUM_CALENDAR
	),
	{
	    task_id => 'REALM_FEATURE_FORM',
	    control =>
		['!', [[qw(->req auth_realm)], 'type'], '->eq_forum'],
	},
	qw(
	    FORUM_EDIT_FORM
	    FORUM_FILE_TREE_LIST
	    GROUP_TASK_LOG
	    FORUM_MAIL_THREAD_ROOT_LIST
	    FORUM_CREATE_FORM
	    FORUM_MOTION_LIST
	    GROUP_USER_LIST
	    FORUM_TUPLE_USE_LIST
	    FORUM_CRM_THREAD_ROOT_LIST
	),
    ];
}

1;
