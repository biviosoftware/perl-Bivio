# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::TOTPQRCode;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');
use MIME::Base32 ();

my($_UT) = b_use('Model.UserTOTP');
my($_TS) = b_use('Type.TOTPSecret');
my($_SHOW_KEY) = 'show setup key';

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(values => [
        QRCode([sub {
            my($source) = @_;
            return join('', (
                'otpauth://totp/',
                $source->req(qw(auth_user name)),
                '?',
                join('&', map(join('=', @$_), (
                    ['secret', _encoded_secret($self, $source)],
                    ['algorithm', $_UT->get_default_algorithm->get_name],
                    ['digits', $_UT->get_default_digits],
                    ['period', $_UT->get_default_period],
                    ['issuer', 'bivio.com'],
                ))),
            ));
        }], {class => 'totp_qr_code', %{$self->get('qrcode_args')}}),
        DIV(Join([
            Link($_SHOW_KEY, '#', {ID => 'totp_setup_key_toggle'}),
            SPAN(String([sub {
                my($source) = @_;
                my($secret) = _encoded_secret($self, $source);
                my(@parts);
                my($i) = 0;
                while (length($secret)) {
                    b_die('sanity check')
                        if ++$i > 8;
                    push(@parts, substr($secret, 0, 4, ''));
                }
                return join(' ', @parts);
            }]), {ID => 'totp_setup_key', class => 'totp_setup_key'}),
            BR(), BR(),
        ]), {class => 'totp_setup'}),
        InlineJavaScript(Join([
            <<"EOF",
(() => {
    const l = document.getElementById("totp_setup_key_toggle");
    const s = document.getElementById("totp_setup_key");
    l.addEventListener("click", (event) => {
        if (l.innerText == "$_SHOW_KEY") {
            s.style.display = "inline";
            l.style.display = "none";
        }
    });
})();
EOF
        ])),
    ])->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $totp_secret, $qrcode_args) = @_;
    return '"totp_secret" attribute required'
        unless $totp_secret;
    return {
        totp_secret => $totp_secret,
        qrcode_args => $qrcode_args || {},
    };
}

sub _encoded_secret {
    my($self, $source) = @_;
    return MIME::Base32::encode_rfc3548(
        $self->render_simple_attr('totp_secret', $source) || b_die('no secret'));
}

1;
