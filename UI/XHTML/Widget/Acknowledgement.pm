# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Acknowledgement;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('Action.Acknowledgement');
my($_T) = b_use('FacadeComponent.Text');

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
		 unless ($_A->exists_in_facade($req, $label)) {
		     b_warn('invalid acknowledgement label: ', $label);
		     return '';
		 }
                 return vs_text($req, 'acknowledgement', $label);
	    }],
        )),
    );
}

1;
