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
	    SiteAdminDropDown(),
	]),
    );
    return @res;
}

1;
