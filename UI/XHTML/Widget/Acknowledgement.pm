# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Acknowledgement;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub AUTOLOAD {
    return Bivio::UI::ViewLanguage->call_method(
	$AUTOLOAD, 'Bivio::UI::ViewLanguage', @_,
    );
}

sub new {
    return shift->SUPER::new(@_)->put_unless_exists(
	tag => 'div',
	class => 'acknowledgement',
	control => [
	    sub {
		Bivio::Biz::Action->get_instance('Acknowledgement')
		    ->extract_label(shift->get_request);
	    },
	],
        value => [sub {
             my($req) = shift->get_request;
             return Tag(div => Prose(
		 Bivio::UI::Text->get_value(
		     'acknowledgement',
		     $req->get_nested('Action.Acknowledgement', 'label'),
		     $req,
		 )), 'text');
         }],
    );
}

1;
