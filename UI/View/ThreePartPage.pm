# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::ThreePartPage;
use strict;
use Bivio::Base 'Bivio::UI::View::Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = b_use('Agent.TaskId');
my($_WANT_USER_AUTH) = $_TI->is_component_included('user_auth');
my($_C) = b_use('IO.Config');

sub internal_xhtml_adorned {
    my($self) = @_;
    $self->internal_xhtml_adorned_attrs;
    return Page({
	style => view_widget_value('xhtml_style'),
	head => Join([
	    vs_text_as_prose('xhtml_head_title'),
	    view_widget_value('xhtml_head_tags'),
	    EmptyTag(link => {
		control => view_widget_value('xhtml_rss_task'),
		html_attrs => [qw(rel type title href)],
		rel => 'alternate',
		type => 'application/atom+xml',
		title => Prose(
		    vs_text(
			'rsslink', 'title', view_widget_value('xhtml_rss_task')),
		),
		href => URI({
		    task_id => view_widget_value('xhtml_rss_task'),
		    query => undef,
		}),
	    }),
	]),
	body => $self->internal_xhtml_adorned_body,
	xhtml => 1,
	want_page_print => view_widget_value('xhtml_want_page_print'),
    });
}

sub internal_xhtml_adorned_attrs {
    my($self) = @_;
   view_pre_execute(sub {
	my($req) = shift->get_request;
	Bivio::Biz::Model->new($req, 'SearchForm')->process
	    unless $req->unsafe_get('Model.SearchForm');
	return;
    }) if $_TI->unsafe_from_name('SEARCH_LIST')
        && !$self->unsafe_get('view_pre_execute');
    view_put(
	xhtml_title => Join([
	    SPAN_realm(String([qw(auth_realm owner display_name)]), {
		control => vs_realm_type('forum'),
	    }),
	    vs_text_as_prose('xhtml_title'),
	], {join_separator => ' '}),
	vs_pager => '',
	xhtml_body_class => '',
	xhtml_head_tags => '',
	xhtml_rss_task => '',
	xhtml_tools => '',
	xhtml_nav => '',
	xhtml_topic => '',
	xhtml_byline => '',
	xhtml_selector => '',
	xhtml_dock_left => '',
	xhtml_dock_middle => '',
	xhtml_dock_right => JoinMenu([
	    $_C->if_version(8 => sub {_header_right('ForumDropDown')}),
	    _header_right(qw(HelpWiki HELP)),
	    $_WANT_USER_AUTH ? (
		_header_right(qw(UserSettingsForm USER_SETTINGS_FORM)),
		_header_right(qw(UserState LOGIN)),
	    ) : (),
	]),
	xhtml_header_left => vs_text_as_prose('xhtml_logo'),
	xhtml_want_page_print => 0,
	xhtml_main_left => '',
	xhtml_main_right => '',
	xhtml_footer_left => XLink('back_to_top'),
	xhtml_footer_middle => '',
	xhtml_footer_right => vs_text_as_prose('xhtml_copyright'),
	xhtml_want_first_focus => 1,
    );
    view_put(
	xhtml_body_first => Join([
	    EmptyTag(a => {html_attrs => ['name'], name => 'top'}),
            vs_first_focus(view_widget_value('xhtml_want_first_focus')),
	]),
	xhtml_header_right => $_C->if_version(
	    7 => sub {_header_right(qw(SearchForm SEARCH_LIST))},
	    sub {
		return Join([
		    DIV_user_state(view_widget_value('xhtml_dock_right')),
		    _header_right(qw(SearchForm SEARCH_LIST)),
		]);
	    },
	),
	xhtml_header_middle => DIV_nav(view_widget_value('xhtml_nav')),
	xhtml_style => RealmCSS(),
	xhtml_main_middle => Join([
	    Acknowledgement(),
	    MainErrors(),
	    DIV_main_top(Join([
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('vs_pager'),
		], {
		    join_separator => DIV_sep(''),
		})),
		DIV_title(view_widget_value('xhtml_title')),
		DIV_selector(
		    view_widget_value('xhtml_selector')),
		DIV_topic(view_widget_value('xhtml_topic')),
		DIV_byline(view_widget_value('xhtml_byline')),
	    ])),
	    DIV_main_body(view_widget_value('xhtml_body')),
	    DIV_main_bottom(
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('vs_pager'),
		], {
		    join_separator => EmptyTag(DIV => 'sep'),
		})),
	    ),
	]),
    );
    return;
}

sub internal_xhtml_adorned_body {
    my($self) = @_;
    return Join([
	view_widget_value('xhtml_body_first'),
	$_C->if_version(7 => sub {$self->internal_xhtml_grid3('dock')}),
	$self->internal_xhtml_grid3('header'),
	$self->internal_xhtml_grid3('main'),
	$self->internal_xhtml_grid3('footer'),
    ]);
}

sub internal_xhtml_grid3 {
    my(undef, $name) = @_;
    return vs_grid3($name);
}

sub _header_right {
    my($widget, $task) = @_;
    return ''
	if $task && !$_TI->unsafe_from_name($task);
    return If(vs_constant("ThreePartPage_want_$widget"), vs_call($widget));
}

1;
