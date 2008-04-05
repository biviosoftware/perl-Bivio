# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormFieldError;
use strict;
use Bivio::Base 'Widget.IfFieldError';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FCF) = __PACKAGE__->use('FacadeComponent.Font');
my($_F) = __PACKAGE__->use('UI.Facade');

sub initialize {
    my($self) = @_;
    $self->initialize_attr(label => '');
    return shift->SUPER::initialize(@_);
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->req;
    my($p, $s) = $_FCF->format_html('form_field_error', $req);
    $$buffer .= $p
	. ($_F->get_from_request_or_self($req)->unsafe_get('FormError')
	    || $self->use('Bivio::UI::HTML::FormErrors')
	)->to_html(
	    $source,
	    $self->resolve_form_model($source),
	    $self->render_simple_attr(field => $source),
	    $self->render_simple_attr(label => $source),
	    $self->resolve_attr(control => $source),
	)
	. $s
	. "<br />\n";
    return;
}

1;
