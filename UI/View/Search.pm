# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Search;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_byline_control {
    return 1;
}

sub list {
    my($self) = @_;
    return $self->internal_body(vs_paged_list(SearchList => [
	['result_title', {
	    column_widget => Link(
		Join([
		    SPAN_title(String(['result_title'])),
		    SPAN_excerpt(String(['result_excerpt'])),
		    SPAN_byline(Join([
			SPAN_author(String(['result_author'])),
			SPAN_date(DateTime(['RealmFile.modified_date_time'])),
		    ]), {
			control => $self->internal_byline_control,
		    }),
		]),
		['result_uri'],
	    ),
	}],
    ], {
	class => 'paged_list search_results',
	show_headings => 0,
    })),
}

1;
