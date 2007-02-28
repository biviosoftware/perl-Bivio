# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Wiki;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub edit {
    return shift->internal_body(vs_simple_form(WikiForm => [
	'WikiForm.RealmFile.path_lc',
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    TextArea({
		field => 'content',
		rows => 30,
		cols => 60,
	    }),
	]),
    ]));
}

sub not_found {
    return shift->internal_body_from_name_as_prose;
}

sub view {
    view_put(
#TODO: Move to facade
	xhtml_topic => If(
	    ['!', 'Action.WikiView', 'is_start_page'],
	    String(['Action.WikiView', 'name']),
	),
	xhtml_byline => If(
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
	xhtml_tools => If(
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
