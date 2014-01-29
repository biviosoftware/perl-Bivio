# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::ThreePartPage;
use strict;
use Bivio::Base 'Bivio::UI::View::Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = b_use('Agent.TaskId');
my($_WANT_USER_AUTH) = $_TI->is_component_included('user_auth');
my($_C) = b_use('IO.Config');
b_use('IO.Config')->register(my $_CFG = {
    center_replaces_middle => 0,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_xhtml_adorned {
    my($self) = @_;
    $self->internal_xhtml_adorned_attrs;
    return Page({
	style => view_widget_value('xhtml_style'),
	head => Join([
	    view_widget_value('xhtml_adorned_title'),
	    view_widget_value('xhtml_head_tags'),
	    vs_rss_task_in_head(),
	]),
	body => $self->internal_xhtml_adorned_body,
	body_class => view_widget_value('xhtml_body_class'),
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
	xhtml_title => vs_xhtml_title(),
	vs_pager => '',
	xhtml_adorned_title => vs_text_as_prose('xhtml_head_title'),
	xhtml_body_class => '',
	xhtml_head_tags => '',
	xhtml_rss_task => '',
	xhtml_tools => '',
	xhtml_nav => '',
	xhtml_topic => '',
	xhtml_byline => '',
	xhtml_selector => '',
	xhtml_dock_left => _if_want(
	    'dock_left_standard',
	    undef,
	    vs_text_as_prose('xhtml_dock_left_standard'),
        ),
	_center_replaces_middle('xhtml_dock_middle') => '',
	xhtml_dock_right => JoinMenu([
	    $_C->if_version(8 => sub {_if_want('ForumDropDown')}),
	    _if_want(qw(HelpWiki HELP)),
	    $_WANT_USER_AUTH ? (
		_if_want(qw(UserSettingsForm USER_SETTINGS_FORM)),
		_if_want(qw(UserState LOGIN)),
	    ) : (),
	]),
	xhtml_header_left => vs_text_as_prose('xhtml_logo'),
	xhtml_want_page_print => 0,
	xhtml_main_left => '',
	xhtml_main_right => '',
	xhtml_footer_left => XLink('back_to_top'),
	_center_replaces_middle('xhtml_footer_middle') => '',
	xhtml_footer_right => vs_text_as_prose('xhtml_copyright'),
	xhtml_want_first_focus => 1,
	xhtml_body_last => '',
    );
    view_put(
	xhtml_body_first => Join([
	    EmptyTag(a => {html_attrs => ['name'], name => 'top'}),
            vs_first_focus(view_widget_value('xhtml_want_first_focus')),
	    Script('b_log_errors'),
	]),
	xhtml_header_right => $_C->if_version(
	    7 => sub {_if_want(qw(SearchForm SEARCH_LIST))},
	    sub {
		return Join([
		    DIV_user_state(view_widget_value('xhtml_dock_right')),
		    _if_want(qw(SearchForm SEARCH_LIST)),
		]);
	    },
	),
	_center_replaces_middle('xhtml_header_middle')
	    => DIV_nav(view_widget_value('xhtml_nav')),
	xhtml_style => RealmCSS(),
	_center_replaces_middle('xhtml_main_middle') => Join([
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
	view_widget_value('xhtml_body_last'),
    ]);
}

sub internal_xhtml_grid3 {
    my(undef, $name) = @_;
    return Grid(
	[[map(
	    {
		my($n) = "${name}_$_";
		Join(
		    [view_widget_value("xhtml_$n")],
		    {cell_class => $n},
		)->b_widget_label($n);
	    }
	    'left', _center_replaces_middle('middle'), 'right',
	)]],
	{
	    class => $name,
	    hide_empty_cells => 1,
	},
    )->b_widget_label($name);
}

sub _center_replaces_middle {
    my($name) = @_;
    $name =~ s/middle/center/
	if $_CFG->{center_replaces_middle};
    return $name;
}

sub _if_want {
    my($name, $task, $widget) = @_;
    return ''
	if $task && !$_TI->unsafe_from_name($task);
    $widget ||= $name;
    return If(
	vs_constant("ThreePartPage_want_$name"),
	ref($widget) ? $widget : vs_call($widget),
    );
}

1;
