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

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control_on_value => DropDown(
	    vs_text_as_prose('SiteAdminDropDown_label'),
	    DIV_dd_menu(TaskMenu([
		@{$self->get_or_default(extra_items => [])},
                map(XLink($_),
                    b_use('Model.UserCreateForm')
			->if_unapproved_applicant_mode(sub {'applicants'}),
                    'all_users',
                    'substitute_user',
                ),
	    ]), {id => 'admin_drop_down'}),
	),
    );
    return shift->SUPER::initialize(@_);
}

1;
