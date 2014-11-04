# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget.SiteAdminControl';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_F) = b_use('UI.Facade');

sub NEW_ARGS {
    return [qw(?extra_items)];
}

sub TASK_MENU_LIST {
    return (
	map(
	    {
		xlink => XLink({
		    facade_label => $_,
		    control => vs_constant("want_$_"),
		}),
		sort_label => "xlink.$_",
		label => 'none',
	    },
	    qw(
		substitute_user
		all_users
		remote_copy
		applicants
		task_log
		site_reports
	    ),
	),
	'EMAIL_ALIAS_LIST_FORM',
	@{$_F->if_2014style(
	    [
		If([qw(auth_realm type ->eq_forum)], Join([
		    LI('', 'divider'),
		    LI(Join([
			String([qw(auth_realm owner display_name)]),
			' Forum',
		    ]), 'dropdown-header'),
		]))->put(task_menu_no_wrap => 1),
		'FORUM_CREATE_FORM',
		'FORUM_EDIT_FORM',
		'GROUP_USER_LIST',
	    ],
	    [],
	)},
    );
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control_on_value => DropDown(
	    vs_text_as_prose('SiteAdminDropDown_label'),
	    TaskMenu([
		@{$self->get_or_default(extra_items => [])},
                $self->TASK_MENU_LIST,
	    ], {
		want_sorting => If2014Style(0, 1),
		class => 'dd_menu',
	    })
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
