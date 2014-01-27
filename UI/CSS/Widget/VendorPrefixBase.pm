# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::VendorPrefixBase;
use strict;
use Bivio::Base 'CSSWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put(
	values => [
	    map(
		(($_ ? "-$_-$name" : $name), ':', $value, ';'),
	       '',
	       qw(
	           webkit
		   moz
		   ms
		   o
	       ),
	    ),
	    "\n",
	],
    );
    return shift->SUPER::initialize(@_);
}

1;
