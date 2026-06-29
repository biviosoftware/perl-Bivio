# Copyright (c) 2008-2026 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::XHTML::Widget::XLinkLabel;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;
use Scalar::Util ();

sub qualify_label {
    my(undef, $label) = @_;
    return "xlink.$label";
}

sub initialize {
    my($self) = @_;
    # Weakly capture $self so the stored Prose's code_ref does not form a reference-cycle
    Scalar::Util::weaken(my $w = $self);
    $self->initialize_attr(_prose => Prose([sub {
        my($source) = @_;
        return vs_text(
            $source->req,
            $w->qualify_label(
                $w->render_simple_attr('value', $source),
            ),
        );
    }]));
    return shift->SUPER::initialize(@_);
}

sub render {
    shift->render_attr(_prose => @_);
    return;
}

1;
