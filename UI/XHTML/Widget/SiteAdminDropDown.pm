# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SiteAdminDropDown;
use strict;
use Bivio::Base 'XHTMLWidget.SiteAdminControl';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_UAM) = b_use('Model.UserRegisterForm')->unapproved_applicant_mode_config;

sub NEW_ARGS {
    return [qw(?extra_items)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control_on_value => DropDown(
	    vs_text_as_prose('SiteAdminDropDown_label'),
	    DIV_dd_menu(TaskMenu([
		@{$self->get_or_default(extra_items => [])},
		map(+{
		    task_id => $_,,
		    realm => vs_constant('site_admin_realm_name'),
		},
		    $_UAM ? qw(SITE_ADMIN_UNAPPROVED_APPLICANT_LIST) : (),
		    'SITE_ADMIN_USER_LIST',
		    'SITE_ADMIN_SUBSTITUTE_USER',
		),
	    ]), {id => 'admin_drop_down'}),
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
