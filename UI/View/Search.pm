# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Search;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_GLYPH_MAP) = {
    map({
	$_->[0] => 'b_icon_' . $_->[1];
    } (
	[qw(wikidataname cog)],
	[qw(mailfilename envelope)],
	[qw(filename file)],
	[qw(wikiname paperclip)],
	[qw(blogfilename comment)],
	[qw(image picture)],
    )),
};

sub internal_byline_control {
    return ['show_byline'];
}

sub list {
    my($self) = @_;
    my($list) = 'SearchList';
    return $self->internal_body(
	Join([
	    If(
		Or(_has_query($list, 'prev'), _has_query($list, 'next')),
		SPAN_pagination(' '),
	    ),
	    vs_paged_list(
		$list,
		_list($self),
		{
		    b_use('UI.Facade')->is_2014style
			? () : (class => 'paged_list b_search_results'),
		    show_headings => 0,
		},
	    ),
	]),
    ),
}

sub suggest_list_json {
    my($self) = @_;
    view_put(json_body => JSONValueLabelPairList({
	list_class => 'SearchSuggestList',
	value_widget => String(['result_uri']),
	label_widget => Join([
	    Link(
		DIV_row(
		    DIV(
			Join([
			    SPAN('', {
				class => String([
				    sub {
					my($source) = @_;
					return $_GLYPH_MAP->{
					    $source->get('result_uri')
						=~ /\.(jpg|jpeg|gif|bmp|png)$/
						    ? 'image'
							: lc($source->get('result_type'))
						    };
				    },
				]),
			    }),
			    SPAN_bivio_suggest_title(String(['result_title'])),
			    SPAN_bivio_suggest_excerpt(String(['result_excerpt'])),
			], ' '),
			{
			    class => 'col-xs-12 bivio_suggest_headline',
			},
		    ),
		),
		['result_uri'],
	    ),
	]),
    }));
    return;
}

sub _has_query {
    my($list, $dir) = @_;
    return [["Model.$list", '->get_query'], "has_$dir"];
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
			DIV_date(
			    If2014Style(
				vs_smart_date(),
				DateTime(['RealmFile.modified_date_time']),
			    ),
			),
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
