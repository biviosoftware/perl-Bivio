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
            my($secret) = $source->req(qw(form_model totp_secret));
            return join('', (
                'otpauth://totp/',
                $source->req(qw(auth_user name)),
                '?',
                join('&', map(join('=', @$_), (
                    ['secret', MIME::Base32::encode_rfc3548($secret)],
                    ['algorithm', $_UT->get_default_algorithm->get_name],
                    ['digits', $_UT->get_default_digits],
                    ['period', $_UT->get_default_period],
                    ['issuer', 'bivio.com'],
                ))),
            ));
        }], {class => 'totp_qr_code'}),
        DIV(Join([
            Link($_SHOW_KEY, '#', {ID => 'totp_setup_key_toggle'}),
            SPAN(String([sub {
                my($source) = @_;
                my($secret) = MIME::Base32::encode_rfc3548($source->req(qw(form_model totp_secret)));
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

1;
