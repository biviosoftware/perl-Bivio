# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Search;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub list {
    return shift->internal_body(
	Join([
# 	    vs_simple_form(SearchForm => [
# 		[FormField('SearchForm.search')],
# 		'*ok_button',
# 	    ]),
	    vs_paged_list(SearchList => [
		['RealmFile.modified_date_time', {
		    column_data_class => 'last_update',
		    column_heading_class => 'last_update',
		}],
		['RealmFile.path', {
		    column_data_class => 'long_text item',
		    column_heading_class => 'item',
#TODO: Need to fix up page
		    column_widget => Link(
#HTML?
			String(['result_excerpt']),
			['result_uri'],
		    ),
		}],
	    ]),
	]),
    );
}

1;
