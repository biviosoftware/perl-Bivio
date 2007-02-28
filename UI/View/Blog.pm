# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Blog;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub edit {
    return shift->internal_body(vs_simple_form(BlogEditForm => [
	['BlogEditForm.title', {
	    size => 57,
	}],
	'BlogEditForm.RealmFile.is_public',
	_edit(),
    ]));
}

sub create {
    return shift->internal_body(vs_simple_form(BlogCreateForm => [
	'BlogCreateForm.title',
	_edit(),
    ]));
}

sub detail {
    return shift->internal_put_base_attr(
	topic => String([qw(Model.BlogList title)]),
	byline => Join([
	    'posted on ',
	    DateTime([qw(Model.BlogList ->get_creation_date_time)]),
	    ' (',
	    'last edited by ',
	    MailTo(
		[qw(Model.BlogList Email.email)],
		[qw(Model.BlogList RealmOwner.display_name)],
	    ),
	    ' on ',
	    DateTime(['Model.BlogList', 'RealmFile.modified_date_time']),
	    ')',
	]),
	tools => TaskMenu([
	    {
		task_id => 'FORUM_BLOG_EDIT',
		path_info => [qw(Model.BlogList path_info)],
	    },
	    'FORUM_BLOG_CREATE',
	]),
	body => vs_paged_detail(
	    'BlogList',
	    [qw(THIS_LIST FORUM_BLOG_LIST)],
#TODO: Replace with proper blog widget that *partially* reuses wiki markup
 	    DIV_blog(
		DIV(DIV_text([qw(Model.BlogList ->render_html)]),
#TODO: multipel classes
 		{class => If(
 		    ['Model.BlogList', 'RealmFile.is_public'],
 		    'public', 'private')},
 	    )),
	),
    );
}

sub list {
    return shift->internal_put_base_attr(
	rss_task => 'FORUM_BLOG_RSS',
	tools => TaskMenu(['FORUM_BLOG_CREATE']),
	menu => Join([
#TODO: Move to FacadeBase
	    DIV_heading('Recent Entries'),
	    UL(List('BlogRecentList', [
		LI(vs_link(['title'], URI({
		    task_id => 'FORUM_BLOG_DETAIL',
		    path_info => ['path_info'],
		}))),
	    ])),
	]),
	body => DIV_blog(Join([
	    DIV_list(vs_paged_list(BlogList => List(BlogList => [
		DIV(Join([
#		    DIV_heading(Join([
# 			DIV_status(
# 			    If(['RealmFile.is_public'],
# 			       String('public'),
# 			       String('private'),
# 			   ),
# 			),
			DIV_heading(vs_link(['title'], URI({
			    task_id => 'FORUM_BLOG_DETAIL',
			    path_info => ['path_info'],
			}))),
#		    ])),
		    DIV_text(['->render_html_excerpt']),
# 		    DIV_byline2(Join([
# #TODO: Move text to FacadeBase.  PRobably share with wiki
# 			DIV(Join([
# 			    'last edited by ',
# 			    MailTo(['Email.email'],
# 			    ['RealmOwner.display_name']),
# 			    ' on ',
# 			    DateTime(['RealmFile.modified_date_time']),
# 			])),
# 			DIV(Join([
# 			    'created on ',
# 			    DateTime(['->get_creation_date_time']),
# 			])),
# 		    ])),
		    DIV_menu(Link(vs_text('title.FORUM_BLOG_EDIT'), URI({
			task_id => 'FORUM_BLOG_EDIT',
			path_info => ['path_info'],
		    }), {
			control => Bivio::Agent::TaskId->FORUM_BLOG_EDIT,
		    })),
		]),
		{class => If(['RealmFile.is_public'], 'public', 'private')},
	    ),
	]))),
    ])));
}

sub recent_rss {
    my($self) = @_;
    view_main(RSSPage(BlogList => {
	pubDate => String(
	    ['RealmFile.modified_date_time', 'HTMLFormat.DateTime', 'RFC822'],
	),
#TODO: Task should be title.
	title => String(['title']),
	link => String([
	    sub {
		my($list) = @_;
#TODO: Refactor or add XML(?) link widget that formats full http URI
# as required by some RSS readers
		return $list->get_request->format_http({
		    task_id => 'FORUM_BLOG_DETAIL',
		    path_info => $list->get('path_info'),
		});
	    },
	]),
	description => Join([
	    '<![CDATA[',
	    ['->render_html'],
	    ']]>',
	]),
    }, {
	source_task => 'FORUM_BLOG_LIST',
    }));
    return;
}

sub _edit {
    return Join([
	FormFieldError({
	    field => 'body',
	    label => 'text',
	}),
	TextArea({
	    field => 'body',
	    rows => 30,
	    cols => 60,
	}),
    ], {
	cell_class => 'blog_textarea',
    });
}

1;
