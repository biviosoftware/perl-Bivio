# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Acknowledgement;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = __PACKAGE__->use('Action.Acknowledgement');
my($_T) = __PACKAGE__->use('FacadeComponent.Text');

sub new {
    return shift->SUPER::new(@_)->put_unless_exists(
	tag => 'div',
	class => 'acknowledgement',
	tag_if_empty => 0,
        value => DIV_text(Prose(
	    [sub {
	         my($req) = shift->req;
	         return ''
		     unless my $label = $_A->extract_and_delete_label($req);
                 return vs_text($req, 'acknowledgement', $label);
	    }],
        )),
    );
}

1;
