# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_xhtml_adorned {
    my($self) = shift;
    my(@res) = $self->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(
	xhtml_dock_left => TaskMenu([
	    'SITE_WIKI_VIEW',
	    'FORUM_CALENDAR',
	    'FORUM_FILE',
	    'FORUM_MAIL_THREAD_ROOT_LIST',
	    'FORUM_CRM_THREAD_ROOT_LIST',
	    'GROUP_USER_LIST',
	    'FORUM_WIKI_VIEW',
	    If(['->is_site_admin'],
	       DropDown(
		   String('Admin'),
		   DIV_dd_menu(TaskMenu([
		       map(+{
			   task_id => $_,
			   realm => vs_constant('site_admin_realm_name'),
		       }, qw(
			   SITE_ADMIN_USER_LIST
			   SITE_ADMIN_SUBSTITUTE_USER
			   SITE_ADMIN_UNAPPROVED_APPLICANT_LIST
		       )),
		   ]), {id => 'admin_drop_down'}),
	       ),
	   ),
	]),
    );
    return @res;
}

1;
