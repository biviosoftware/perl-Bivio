# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ProgressBar;
use strict;
use Bivio::Base 'HTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

# maximum_text : code_ref
#
# The maximum value as text (ex. "50.0MB")
#
# percent : code_ref
#
# The current percent value.

my($_RENDER_KEY) = __PACKAGE__ . 'rendered';

sub NEW_ARGS {
    return [qw(percent maximum_text ?class)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	class => 'b_progress_bar',
	tag => 'div',
	value => Join([
	    SPAN_b_progress_img(
		ClearDot(Join([Or($self->get('percent'), 1), '%']))),
	    SPAN_b_text(
		String(
		    Join([
			$self->get('percent'),
			'% of ',
			$self->get('maximum_text'),
		    ]),
		    {escape_html => 1},
		),
	    ),
	]),
    );
    return shift->SUPER::initialize(@_);
}


1;
