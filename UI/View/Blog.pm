# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Blog;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('IO.Config');

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
	menu => Join([
	    DIV_heading('Recent Entries'),
	    UL(List('BlogRecentList', [
		LI(vs_link(['title'], URI({
		    task_id => _access_mode('FORUM_BLOG_DETAIL'),
		    path_info => ['path_info'],
		}))),
	    ])),
	]),
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
	    [THIS_LIST => _access_mode('FORUM_BLOG_LIST')],
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
#TODO: Fix this
	rss_task => _access_mode('FORUM_BLOG_RSS'),
	tools => TaskMenu(['FORUM_BLOG_CREATE']),
	menu => Join([
#TODO: Move to FacadeBase
	    DIV_heading('Recent Entries'),
	    UL(List('BlogRecentList', [
		LI(vs_link(['title'], URI({
		    task_id => _access_mode('FORUM_BLOG_DETAIL'),
		    path_info => ['path_info'],
		}))),
	    ])),
	]),
	body => DIV_blog(Join([
	    DIV_list(vs_paged_list(BlogList => List(BlogList => [
		DIV(Join([
		    DIV_heading(Join([
			vs_link(['title'], URI({
			    task_id => _access_mode('FORUM_BLOG_DETAIL'),
			    path_info => ['path_info'],
			})),
		    ])),
		    DIV_text(Join([
			DIV_excerpt(['->render_html_excerpt']),
			' ... ',
			Link('[more]', URI({
			    task_id => _access_mode('FORUM_BLOG_DETAIL'),
			    path_info => ['path_info'],
			}), 'more'),
		    ])),
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

sub recent_xml {
    return shift->internal_body(
	Tag(rss =>
	    Tag(channel => Join([
		map(
		    Tag($_ => XML(vs_text_as_prose("rsspage.BlogList.$_"))),
		    qw(title description),
		),
		Tag(link => XML(URI({
		    task_id => 'FORUM_BLOG_LIST',
		    query => undef,
		}))),
		Tag(language => 'en-us'),
		WithModel(BlogList => Join([
		    TagField('title'),
		    Tag(link => XML(URI({
			task_id => _access_mode('FORUM_BLOG_DETAIL'),
			query => undef,
			path_info => ['path_info'],
		    }))),
		    Tag(description => CDATA(['->render_html'])),
		])),
	    ])),
	    {xml_version => '2.0'},
	),
    );
}

sub _access_mode {
    my($task) = @_;
    return $_C->if_version(
	3 => sub {
	    return $task;
	},
	sub {
	    (my $p = $task) =~ s/(?<=^FORUM_)/PUBLIC_/;
	    return [
		sub {
		    my($source, $private, $public) = @_;
		    shift->req('Type.AccessMode')->eq_private
			? $private : $public;
		},
		$task, $p,
	    ];
	},
    );
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
