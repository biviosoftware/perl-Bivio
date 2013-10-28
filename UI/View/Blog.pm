# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Blog;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');

sub edit {
    my($self, $form) = @_;
    $form ||= 'BlogEditForm';
    my($editor) = b_use('View.Wiki')->use_wysiwyg
	? \&CKEditor
	: \&TextArea;
    return $self->internal_body(vs_simple_form($form => [
	["$form.title", {
	    size => 57,
	}],
	"$form.RealmFile.is_public",
	Join([
	    FormFieldError({
		field => 'body',
		label => 'text',
	    }),
	    $editor->({
		field => 'body',
		rows => 30,
		cols => 80,
		%{b_use('View.Wiki')->get_image_folders},
		use_public_image_folder =>
		    ["Model.$form", 'RealmFile.is_public'],
	    }),
	], {
	    cell_class => 'blog_textarea',
	}),
    ]));
}

sub create {
    return shift->edit('BlogCreateForm');
}

sub detail {
    return shift->internal_put_base_attr(
	tools => TaskMenu([
	    {
		task_id => 'FORUM_BLOG_EDIT',
		path_info => [qw(Model.BlogList path_info)],
	    },
	    'FORUM_BLOG_CREATE',
	]),
	body => vs_paged_detail(
	    'BlogList',
	    [THIS_LIST => 'FORUM_BLOG_LIST'],
 	    DIV_blog(Join([
		WithModel('BlogList', _blog_title(0)),
		WithModel('BlogList', _blog_byline()),
		DIV_text(
		    WikiText({
			value => ['Model.BlogList', 'body'],
			name => ['Model.BlogList', 'path_info'],
		    }),
		    {
			ITEMSCOPE => 'itemscope',
			ITEMPROP => 'text',
		    },
		),
	    ]), {
		ITEMPROP => 'blogPost',
		ITEMSCOPE => 'itemscope',
		ITEMTYPE => 'http://schema.org/BlogPosting',
	    }),
	),
    );
}

sub list {
    return shift->internal_put_base_attr(
	rss_task => 'FORUM_BLOG_RSS',
	tools => TaskMenu(['FORUM_BLOG_CREATE']),
	body => DIV_blog(DIV_list(
	    vs_paged_list(BlogList => List(BlogList => [
		DIV(Join([
		    _blog_title(1),
		    _blog_byline(),
		    DIV_text(Join([
			DIV_excerpt(String(['->get_rss_summary'])),
			BR(),
			DIV(
			    A('Read More', {
				HREF => URI({
				    task_id => 'FORUM_BLOG_DETAIL',
				    path_info => ['path_info'],
				})
			    })->put(class => 'b_button_link b_ok_button_link'),
			)->put(class => 'b_align_e'),
			BR(),
		    ]), {
			ITEMSCOPE => 'itemscope',
			ITEMPROP => 'text',
		    }),
		]), {
		    ITEMPROP => 'blogPost',
		    ITEMSCOPE => 'itemscope',
		    ITEMTYPE => 'http://schema.org/BlogPosting',
		}),
	    ])),
	    {
		ITEMPROP => 'blogPosts',
		ITEMSCOPE => 'itemscope',
		ITEMTYPE => 'http://schema.org/BlogPosting',
	    }), {
		ITEMSCOPE => 'itemscope',
		ITEMTYPE => 'http://schema.org/Blog',
	    }),
    );
}

sub list_rss {
    return shift->internal_body(AtomFeed('BlogList'));
}

sub _blog_byline {
    return DIV_blog_byline(Join([
	If(['->unsafe_get_author_image_uri'],
	   SPAN_blog_img(Image(
	       ['->unsafe_get_author_image_uri'],
	   ),
	)),
	SPAN_blog_author(Join([
	    SPAN(
		String(['RealmOwner.display_name']),
		{
		    ITEMPROP => 'author',
		    ITEMSCOPE => 'itemscope',
		},
	    ),
	    BR(),
	    SPAN(Join([
		String([$_DT, '->english_day_of_week',
			['->get_creation_date_time']]),
		', ',
		DateTime(['->get_creation_date_time'],
			 'FULL_MONTH_DAY_AND_YEAR'),
	    ]), {
		ITEMPROP => 'dateCreated',
		ITEMSCOPE => 'itemscope',
	    }),
	])),
	DIV_clear(vs_blank_cell()),
    ]));
}

sub _blog_title {
    my($title_as_link) = @_;
    my($title) = SPAN(String(['title']), {
	ITEMPROP => 'headline',
	ITEMSCOPE => 'itemscope',
    });
    return DIV_blog_title(
	$title_as_link
	    ? vs_link($title, URI({
		task_id => 'FORUM_BLOG_DETAIL',
		path_info => ['path_info'],
	    }))
	    : $title,
    );
}

1;
