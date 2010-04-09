# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
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
	xhtml_dock_left => [sub {
            return vs_text_as_prose('xhtml_dock_left_standard');
	}],
	xhtml_dock_center => Link(String('PetShop'), 'SITE_ROOT'),
	xhtml_header_center => IfWiki(
	    '/StartPage',
	    WikiText('@h2 inline WikiText btest'),
	    IfWiki(
		'/WikiValidator_NOT_OK',
		WikiText('@invalidwikitag'),
	    ),
	),
	xhtml_footer_left => Join([
	    XLink('back_to_top'),
	    DIV_pet_task_info(TaskInfo({})),
	]),
    );
    return @res;
}

1;
