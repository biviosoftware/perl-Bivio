# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ForumTaskMenu;
use strict;
use Bivio::Base 'XHTMLWidget.TaskMenu';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_TI) = b_use('Agent.TaskId');

my($_PARENT_MAP, $_PARENT_TASK) = _make_parent_map({
    FORUM_WIKI_VIEW => [qw(
        FORUM_WIKI_EDIT
        FORUM_WIKI_NOT_FOUND
        FORUM_WIKI_VERSIONS_LIST
        FORUM_WIKI_VERSIONS_DIFF
        SITE_WIKI_VIEW
    )],
    FORUM_MAIL_THREAD_ROOT_LIST => [qw(
        FORUM_MAIL_THREAD_ROOT_LIST
        FORUM_MAIL_THREAD_LIST
        FORUM_MAIL_FORM
        FORUM_MAIL_PART
        FORUM_MAIL_SHOW_ORIGINAL_FILE
        GROUP_MAIL_DELETE_FORM
        FORUM_MAIL_BOUNCE_LIST
        FORUM_MAIL_LIST
        FORUM_MAIL_MSG
        FORUM_PUBLIC_MAIL_LIST
        FORUM_PUBLIC_MAIL_MSG
    )],
    FORUM_FILE_TREE_LIST => [qw(
        FORUM_EASY_FORM
        FORUM_FILE
        FORUM_FILE_MANAGER
        FORUM_FILE_MANAGER_AJAX
        FORUM_FILE_VERSIONS_LIST
        FORUM_FILE_CHANGE
        FORUM_FILE_DELETE_PERMANENTLY_FORM
        FORUM_FILE_OVERRIDE_LOCK
        FORUM_FILE_RESTORE_FORM
        FORUM_FILE_REVERT_FORM
        FORUM_FOLDER_FILE_LIST
        FORUM_FILE_UPLOAD_FROM_WYSIWYG
    )],
    FORUM_MOTION_LIST => [qw(
        FORUM_MOTION_FORM
        FORUM_MOTION_COMMENT
        FORUM_MOTION_VOTE
        FORUM_MOTION_VOTE_LIST
        FORUM_MOTION_COMMENT_LIST
        FORUM_MOTION_STATUS
        FORUM_MOTION_COMMENT_DETAIL
        FORUM_MOTION_IS_CLOSED
    )],
    FORUM_CALENDAR => [qw(
       FORUM_CALENDAR_EVENT_DELETE
       FORUM_CALENDAR_EVENT_DETAIL
       FORUM_CALENDAR_EVENT_FORM
    )],
    FORUM_BLOG_LIST => [qw(
        FORUM_BLOG_CREATE
        FORUM_BLOG_EDIT
        FORUM_BLOG_DETAIL
    )],
    FORUM_TUPLE_USE_LIST => [qw(
        FORUM_TUPLE_DEF_EDIT
        FORUM_TUPLE_DEF_LIST
        FORUM_TUPLE_EDIT
        FORUM_TUPLE_HISTORY
        FORUM_TUPLE_LIST
        FORUM_TUPLE_SLOT_TYPE_EDIT
        FORUM_TUPLE_SLOT_TYPE_LIST
        FORUM_TUPLE_USE_EDIT
        FORUM_TUPLE_USE_LIST
    )],
    FORUM_CRM_THREAD_ROOT_LIST => [qw(
        FORUM_CRM_FORM
    )],
});

sub NEW_ARGS {
    return [];
}

sub get_select_widget {
    my($self) = @_;
    return ($self, FORM(
        DIV(
            SELECT(
                Join(
                    _options([
                            _tab_tasks(),
                    ]),
                ),
                'form-control',
                {
                    ONCHANGE => 'document.location = this.value;',
                },
            ),
            'form-group',
        ),
        'visible-xs',
    )->put(cell_expand => 1));
}

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(
        want_more_threshold => 5,
        class => 'nav nav-tabs hidden-xs',
        selected_class => 'active',
        want_more_label => String('More'),
        task_map => [
            _tab_tasks(),
        ],
        selected_item => [\&_selected_task],
        cell_expand => 1,
    )->SUPER::initialize(@_);
}

sub is_top_level_tab {
    my($proto, $source) = @_;
    return $_PARENT_MAP->{$source->req('task_id')->get_name};
}

sub _is_selected_task {
    my($source, $name) = @_;
    return _selected_task($source)->equals_by_name($name);
}

sub _make_parent_map {
    my($map) = @_;
    my($parents) = {};
    my($res) = {};

    foreach my $parent (keys(%$map)) {
        $parents->{$parent} = 1;
        foreach my $name (@{$map->{$parent}}) {
            $res->{$name} = $_TI->from_name($parent);
        }
    }
    return ($parents, $res);
}

sub _options {
    my($tasks) = @_;
    return [map(
        If(['->can_user_execute_task', $_->{task_id}],
           OPTION(
               vs_text_as_prose(
                   'task_menu', 'title', 'noglyph',
                   $_->{label} || $_->{task_id},
               ),
               {
                   VALUE => ['->format_uri', $_->{task_id}],
                   SELECTED => If([\&_is_selected_task, $_->{task_id}],
                       "selected"),
               }
           ),
       ),
        @$tasks,
    )];
}

sub _selected_task {
    my($source) = @_;
    my($current) = $source->req('task_id');
    return $_PARENT_TASK->{$current->get_name} || $current;
}

sub _tab_tasks {
    return map(
        +{
            task_id => $_,
            $_ eq 'FORUM_CALENDAR'
                ? (label => 'forum.calendar')
            : $_ eq 'FORUM_MAIL_THREAD_ROOT_LIST'
                ? (label => 'forum.mail_thread_root_list')
            : $_ eq 'FORUM_CRM_THREAD_ROOT_LIST'
                ? (label => 'forum.crm_thread_root_list')
            : (),
        },
        qw(
            FORUM_WIKI_VIEW
            FORUM_MAIL_THREAD_ROOT_LIST
            FORUM_FILE_TREE_LIST
            FORUM_MOTION_LIST
            FORUM_CALENDAR
            FORUM_BLOG_LIST
            FORUM_TUPLE_USE_LIST
            FORUM_CRM_THREAD_ROOT_LIST
        ),
    );
}

1;
