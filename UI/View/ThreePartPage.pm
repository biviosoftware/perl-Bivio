# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::ThreePartPage;
use strict;
use Bivio::Base 'Bivio::UI::View::Base';
use Bivio::UI::ViewLanguageAUTOLOAD;
#
# You must create your own View.Base if you want to use this class.  See
# PetShop's View.Base.
#

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_xhtml_adorned {
    my($self) = @_;
    view_put(
	xhtml_title => Join([
	    SPAN_realm(String([qw(auth_realm owner display_name)]), {
		control => vs_realm_type('forum'),
	    }),
	    vs_text_as_prose('xhtml_title'),
	], {join_separator => ' '}),
	vs_pager => '',
	xhtml_head_tags => '',
	xhtml_rss_task => '',
	xhtml_tools => '',
	xhtml_nav => '',
	xhtml_topic => '',
	xhtml_byline => '',
	xhtml_selector => '',
	xhtml_header_left => vs_text_as_prose('xhtml_logo'),
	xhtml_header_right => vs_text_as_prose('xhtml_user_state'),
	xhtml_main_left => '',
	xhtml_main_right => HelpWiki(),
	xhtml_footer_left => XLink('back_to_top'),
	xhtml_footer_middle => '',
	xhtml_footer_right => vs_text_as_prose('xhtml_copyright'),
    );
    view_put(
	xhtml_header_middle => DIV_nav(view_widget_value('xhtml_nav')),
	xhtml_style => Join([
	    StyleSheet('SITE_CSS'),
	    StyleSheet('FORUM_CSS'),
	    WikiStyle(),
	]),
	xhtml_main_middle => Join([
	    Acknowledgement(),
	    DIV_main_top(Join([
		DIV_tools(Join([
		    view_widget_value('xhtml_tools'),
		    view_widget_value('vs_pager'),
		], {
		    join_separator => EmptyTag(DIV => 'sep'),
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
    return Page({
	style => view_widget_value('xhtml_style'),
	head => Join([
	    vs_text_as_prose('xhtml_head_title'),
	    view_widget_value('xhtml_head_tags'),
	    EmptyTag(link => {
		control => view_widget_value('xhtml_rss_task'),
		html_attrs => [qw(rel type title href)],
		rel => 'alternate',
		type => 'application/rss+xml',
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
	body => Join([
	    EmptyTag(a => {html_attrs => ['name'], name => 'top'}),
            vs_first_focus(),
	    vs_grid3('header'),
	    vs_grid3('main'),
	    vs_grid3('footer'),
	]),
	xhtml => 1,
    });
}

1;
