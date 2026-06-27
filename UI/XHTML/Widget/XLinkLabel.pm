# Copyright (c) 2008-2026 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::XHTML::Widget::XLinkLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub qualify_label {
    my(undef, $label) = @_;
    return "xlink.$label";
}

sub render {
    my($self, $source, $buffer) = @_;
    # Build the Prose transiently rather than storing it on $self: a stored
    # Prose whose code_ref captures $self forms a cycle that leaks per render.
    Prose([sub {
        return vs_text(
            $_[0]->req,
            $self->qualify_label($self->render_simple_attr('value', $_[0])),
        );
    }])->render_transient($source, $buffer);
    return;
}

1;
