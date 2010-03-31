# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Search;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_byline_control {
    return ['show_byline'];
}

sub list {
    my($self) = @_;
    return $self->internal_body(vs_paged_list(SearchList => [
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
    ], {
	class => 'paged_list b_search_results',
	show_headings => 0,
    })),
}

1;
