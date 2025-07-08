# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::QRCode;
use strict;
use Bivio::Base 'HTMLWidget.RawImage';
use MIME::Base64 ();

my($_SU) = b_use('Bivio.ShellUtil');

# sudo yum install qrencode
# sudo yum install perl-MIME-Base32

sub internal_src {
    my($self, $source) = @_;
    my($value) = ${$self->render_attr('value', $source)};
    $self->put(value => MIME::Base64::encode(${$_SU->piped_exec([qw(qrencode -s 8 -o -), $value])}));
    return $self->SUPER::internal_src($source);
}

1;
