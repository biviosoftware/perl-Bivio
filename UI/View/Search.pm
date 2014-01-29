# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Search;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_GLYPH_MAP) = {
    map({
	$_->[0] => 'glyphicon glyphicon-' . $_->[1];
    } (
	[qw(wikidataname cog)],
	[qw(mailfilename envelope)],
	[qw(filename file)],
	[qw(wikiname star)],
	[qw(blogfilename comment)],
	[qw(image picture)],
    )),
};

sub internal_byline_control {
    return ['show_byline'];
}

sub list {
    my($self) = @_;
    return $self->internal_body(
	vs_paged_list(
	    'SearchList',
	    _list($self),
	    {
		class => 'paged_list b_search_results',
		show_headings => 0,
	    },
	),
    ),
}

sub suggest_list_json {
    my($self) = @_;
    view_put(json_body => JSONValueLabelPairList({
	list_class => 'SearchSuggestList',
	value_widget => String(['result_uri']),
	label_widget => Join([
	    Link(
		Join([
		    DIV_row(
			SPAN_headline(
			    Join([
				DIV(
				    SPAN('', {
					class => String([
					    sub {
						my($source) = @_;
						return $_GLYPH_MAP->{
						    $source->get('result_uri')
							=~ /jpg|jpeg|gif|bmp|png/
							? 'image'
							: lc($source->get('result_type'))
						    };
					    },
					]),
				    }),
				    {
					class => 'col-xs-2',
				    },
				),
				DIV(
				    SPAN_title(String(['result_title'])),
				    {
					class => 'col-xs-10',
				    },
				),
			    ]),
			),
		    ),
		    DIV_row(
			DIV(
			    SPAN_excerpt(String([
				sub {
				    my($excerpt) = shift->get('result_excerpt');
				    my($ellipsis) = length($excerpt) >= 57
					? '...' : '';
				    return join(
					'',
					substr($excerpt, 0, 57),
					$ellipsis,
				    );
				},
			    ])),
			    {
				class => 'col-xs-12',
			    },
			),
		    ),
		    DIV_row(
			SPAN_byline(
			    Join([
				DIV(
				    SPAN_author(String(['result_author'])),
				    {
					class => 'col-xs-5',
				    },
				),
				DIV(
				    SPAN_realm(String(['RealmOwner.display_name'])),
				    {
					class => 'col-xs-7',
				    },
				),
			    ]),
			),
			{
			    control => $self->internal_byline_control,
			},
		    ),
		]),
		['result_uri'],
	    ),
	]),
    }));
    return;
}

sub _list {
    my($self) = @_;
    return [
	['result_title', {
	    column_widget => Join([
		Link(
		    Join([
			SPAN_title(String(['result_title'])),
			SPAN_excerpt(String(['result_excerpt'])),
		    ]),
		    ['result_uri'],
		),
		DIV_byline(
		    Join([
			SPAN_author(String(['result_author'])),
			DIV_date(DateTime(['RealmFile.modified_date_time'])),
			DIV_uri(String(['result_uri'])),
			Link(
			    String(['RealmOwner.display_name']),
			    ['result_realm_uri'],
			    'b_realm_uri',
			),
		    ]),
		    {
			control => $self->internal_byline_control,
		    },
		),
	    ]),
	}],
    ];
}

1;
