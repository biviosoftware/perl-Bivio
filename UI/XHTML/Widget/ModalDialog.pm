# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ModalDialog;
use strict;
use Bivio::Base 'Widget.Simple';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(id title body_content ?footer_content)];
}

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(value => DIV(
	DIV(
	    DIV(
		Join([
		    DIV(
			H4($self->get('title'), 'modal-title'),
			'modal-header',
		    ),
		    DIV(
			$self->get('body_content'),
			{
			    class => 'modal-body',
			    ID => $self->get('id') . '_body_content',
			},
		    ),
		    $self->unsafe_get('footer_content')
			? DIV(
			    $self->get('footer_content'),
			    'modal-footer',
			) : (),
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
