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
	'WikiForm.RealmFile.is_public',
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
    return shift->internal_body_prose(<<'EOF');
The page Tag(strong => String(['Action.WikiView', 'name'])); was not
found, and you do not have permission to create it.  Please
Link('contact us', 'GENERAL_CONTACT'); for more information about this error.
<br /><br />
To return to the previous page, click on your browser's back button, or
Link('click here', [['->get_request'], 'task', 'view_task']); to
return to the start page.
EOF
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
