# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::BorderAttr;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;


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
		$self->unsafe_get('border'),
		['border'],
	    ),
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
	    $self->unsafe_get('color')
		? (
		    'border-color: ', $self->get('color'), ";\n",
		    'border-top-color: ',
		        vs_lighter_color($self->get('color'), 0x1c), ";\n",
		    'border-border-color: ',
		        vs_lighter_color($self->get('color'), -0x1c), ";\n",
		)
		: (),
	]),
    );
    return;
}

1;
