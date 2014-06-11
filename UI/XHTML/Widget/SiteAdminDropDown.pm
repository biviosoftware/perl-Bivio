# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget.SiteAdminControl';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
		want_sorting => 1,
		class => 'dd_menu',
	    })
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
