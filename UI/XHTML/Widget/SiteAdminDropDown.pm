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
    return map(
        XLink({
	    facade_label => $_,
	    control => vs_constant("want_$_"),
	}),
	qw(
	    substitute_user
	    all_users
	    remote_copy
	    applicants
	    task_log
	    site_reports
	),
    );
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control_on_value => DropDown(
	    vs_text_as_prose('SiteAdminDropDown_label'),
	    OL(Join([map(LI($_),
		@{$self->get_or_default(extra_items => [])},
                $self->TASK_MENU_LIST,
	    )])),
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
