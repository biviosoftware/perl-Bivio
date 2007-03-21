# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::StyleSheet;
use strict;
use Bivio::Base 'Bivio::UI::HTML::Widget::ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= qq{<style type="text/css">\n<!--\n}
	. ${$self->use('Bivio::Agent::Embed::Dispatcher')
	    ->call_task(
		$source->get_request,
		$self->render_simple_attr('value', $source),
	)} . "\n-->\n</style>\n";
    return;
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= q{<link href="}
	. ${$self->render_attr('value', $source)}
	. qq{" rel="stylesheet" type="text/css">\n};
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    $self->initialize_attr(control => [
	['->get_request'], 'Bivio::UI::Facade', 'want_local_file_cache',
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('value');
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(value)], \@_);
}

1;
