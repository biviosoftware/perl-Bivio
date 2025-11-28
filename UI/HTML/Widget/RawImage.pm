# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::RawImage;
use strict;
use Bivio::Base 'HTMLWidget.Image';

sub internal_new_args {
    my($args) = shift->SUPER::internal_new_args(@_);
    return {
        %$args,
        value => $args->{src},
        src => '',
    };
}

sub internal_src {
    my($self, $source) = @_;
    my($value) = ${$self->render_attr('value', $source)};
    my($mime_type) = $self->render_simple_attr('mime_type', $source) || 'image/png';
    my($encoding) = $self->render_simple_attr('mime_type', $source) || 'base64';
    return join('', 'data:', $mime_type, ';', $encoding, ',', $value);
}

1;
