# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::Border;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_static_attrs {
    my($proto, $value, $attrs) = @_;
    return ()
	unless defined($value);
    return map((
	$_ . ':',
	$value,
	";\n",
    ), @$attrs);
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	value => Join([
	    $self->get_static_attrs(
		$self->unsafe_get('radius'),
		[qw(
	            -webkit-border-radius
		    -moz-border-radius
		    -ms-border-radius
		    -o-border-radius
		    border-radius
	        )],
	    ),
	]),
    );
    return;
}

1;
