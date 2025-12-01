# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::QRCode;
use strict;
use Bivio::Base 'HTMLWidget.RawImage';
use MIME::Base64 ();

my($_SU) = b_use('Bivio.ShellUtil');

Bivio::IO::Config->register(my $_CFG = {
    default_size => 8,
    default_dpi => 300,
    default_level => 'L',
    default_margin => 0,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_src {
    my($self, $source) = @_;
    my($value) = ${$self->render_attr('value', $source)};
    my($args) = [];
    foreach my $a (qw(size dpi level margin)) {
        push(@$args, '--' . $a, $self->unsafe_get($a) // $_CFG->{'default_' . $a});
    }
    $self->put(value => MIME::Base64::encode(
        ${$_SU->piped_exec(['qrencode', @$args, '-o', '-', $value])}));
    return $self->SUPER::internal_src($source);
}

1;
