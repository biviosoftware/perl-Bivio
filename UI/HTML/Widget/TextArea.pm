# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TextArea;
use strict;
use Bivio::Base 'HTMLWidget.InputBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::HTML::Widget::TextArea> draws a C<INPUT> tag with
# attribute C<TYPE=TEXTAREA>.
#
# field : string (required)
#
# Name of the form field.
#
# form_model : array_ref (required, inherited, get_request)
#
# Which form are we dealing with.
#
# rows : int (required)
#
# The number of rows to show.
#
# cols : int (required)
#
# The number of character columns to show.
#
# readonly : boolean (optional) [0]
#
# Don't allow text-editing

my($_A) = b_use('IO.Alert');

sub initialize {
    my($self) = @_;
    $_A->warn_deprecated(
	'edit_attributes not supported, use ATTR => value form instead')
	if $self->unsafe_get('edit_attributes');
    return shift->put_unless_exists(
	tag => 'textarea',
	$self->unsafe_get('readonly')
	    ? (READONLY => 'readonly')
	    : (),
	map(
	    $self->unsafe_get($_)
		? (uc($_) => $self->get($_))
		: (),
	    qw(rows cols)),
	value => [
	    $self->ancestral_get('form_model'),
	    '->get_field_as_html',
	    $self->get('field'),
	],
    )->SUPER::initialize(@_);
}

1;
