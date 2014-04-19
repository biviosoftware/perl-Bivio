# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::TransformAttr;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_B) = b_use('CSSWidget.BorderAttr');

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	value => Join([
	    $_B->get_static_attrs(
		$self->unsafe_get('transform'),
		[qw(
		    transform
		    -ms-transform
		    -webkit-transform
	        )],
	    ),
	]),
    );
    return;
}

1;
