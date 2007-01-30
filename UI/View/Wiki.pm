# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::View::Wiki;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub view {
    view_put(
#TODO: Move to facade
	base_topic => If(
	    ['!', 'Action.WikiView', 'is_start_page'],
	    String(['Action.WikiView', 'name']),
	),
	base_byline => If(
	    ['!', 'Action.WikiView', 'is_start_page'],
	    Join([
		'last edited ',
		If(['Action.WikiView', 'author'],
		   Join([
		       ' by ',
		       MailTo(['Action.WikiView', 'author']),
		   ]),
	       ),
		' on ',
		DateTime(['Action.WikiView', 'modified_date_time']),
	    ]),
	),
	base_tools => If(
	    ['!', 'auth_realm', 'type', '->equals_by_name', 'GENERAL'],
	    TaskMenu([
		{
		    task_id => 'FORUM_WIKI_EDIT',
		    path_info => [qw(Action.WikiView name)],
		    label => 'forum_wiki_edit_page',
		},
		'FORUM_WIKI_EDIT',
	    ]),
	),
    );
    return shift->internal_body(DIV_wiki(['Action.WikiView', 'html']));
}

1;
