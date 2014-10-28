# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Bootstrap::Widget::Acknowledgement;
use strict;
use Bivio::Base 'XHTMLWidget';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_A) = __PACKAGE__->use('Action.Acknowledgement');

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->put(
    	value => Join([
    	    BUTTON('&times;', 'close', {
    		TYPE => 'button',
    		'DATA-DISMISS' => 'alert',
    	    }),
    	    $self->get('value'),
    	]),
    	class => 'alert alert-success alert-dismissable b_alert',
	control => [$_A, '->extract_label', ['->req']],
    );
    return $self;
}

1;
