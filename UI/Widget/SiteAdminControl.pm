# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::SiteAdminControl;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(control_on_value ?control_off_value)];
}

sub initialize {
    return shift->put_unless_exists(
        control => [
	    ['->req'],
	    '->can_user_execute_task',
	    'SITE_ADMIN_USER_LIST',
	    vs_constant('site_admin_realm_name'),
	],
    )->SUPER::initialize(@_);
}
1;
