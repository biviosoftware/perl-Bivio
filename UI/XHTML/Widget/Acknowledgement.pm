# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Acknowledgement;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = __PACKAGE__->use('Action.Acknowledgement');
my($_T) = __PACKAGE__->use('FacadeComponent.Text');

sub new {
    return shift->SUPER::new(@_)->put_unless_exists(
	tag => 'div',
	class => 'acknowledgement',
	control => [sub {$_A->extract_label(shift->get_request)}],
        value => [sub {
             my($req) = shift->get_request;
             return Tag(div => Prose(
		 $_T->get_value(
		     'acknowledgement',
		     $req->get_nested('Action.Acknowledgement', 'label'),
		     $req,
		 )), 'text');
         }],
    );
}

1;
