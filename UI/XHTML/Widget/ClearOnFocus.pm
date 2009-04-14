# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ClearOnFocus;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(values => [
	Script('b_clear_on_focus'),
	# Have we rendered already?
	$self->get('widget')->put(
	    ONFOCUS => Join([
		'b_clear_on_focus(this, "',
		JavaScriptString($self->get('hint_text')),
		'")',
            ]),
	    class => _class($self),
	),
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args(
	[qw(widget hint_text)], \@_);
}

sub _class {
    my($self) =
	@_;
    my($c) = $self->get('widget')->unsafe_get('class');
    return !$c ? 'disabled' : Join([$c, 'disabled'], ' ');
}

1;
