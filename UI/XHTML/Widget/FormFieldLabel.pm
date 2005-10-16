# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::FormFieldLabel;
use strict;
use base 'Bivio::UI::HTML::Widget::String';
use Bivio::UI::HTML::Widget::ControlBase;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get('field');
}

sub internal_new_args {
    shift;
    return Bivio::UI::HTML::Widget::ControlBase->internal_new_args(
	[qw(field label)],
	\@_,
    );
}

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    $self->put(
	value => $self->get('label'),
	string_font => 0,
	cell_class => [sub {
	    my($source, $err) = @_;
	    return $err ? 'label_err' : 'label_ok';
	}, [
	    ['->get_request'],
	    $self->ancestral_get('form_class'),
	    '->get_field_error',
	    $self->get('field'),
	]],
    );
    return shift->SUPER::initialize(@_);
}

1;
