# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ModalDialog;
use strict;
use Bivio::Base 'Widget.Simple';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(id ?header ?body ?footer)];
}

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(value => DIV(
	DIV(
	    DIV(
		Join([
		    map(
			$self->unsafe_get($_)
			    ? DIV(
				$self->get($_),
				{
				    class => "modal-$_",
				    ID => join('_', $self->get('id'), $_),
				},
			    ) : (),
			qw(header body footer),
		    ),
		]),
		'modal-content',
	    ),
	    'modal-dialog',
	),
	'modal fade',
	{
	    ID => $self->get('id'),
	},
    ))->SUPER::initialize(@_);
}

1;
