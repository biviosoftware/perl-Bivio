# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::Shadow;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_B) = b_use('CSSWidget.Border');

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	value => Join([
	    $_B->get_static_attrs(
		$self->unsafe_get('box'),
		[qw(
		    -moz-box-shadow
		    -webkit-box-shadow
		    box-shadow
	        )],
	    ),
	    $_B->get_static_attrs(
		$self->unsafe_get('text'),
		[qw(
                    text-shadow
		    -webkit-text-shadow
		    -moz-text-shadow
	        )],
	    ),
	]),
    );
    return;
}

1;
