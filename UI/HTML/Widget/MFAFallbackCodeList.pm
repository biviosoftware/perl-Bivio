# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::MFAFallbackCodeList;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');

my($_A) = b_use('Action.MFAFallbackCodeList');

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(values => [
        Join([
            'Save the following codes in a secure place. They are your authenticator fallback codes. If you don\'t have access to your authenticator app you will need to enter one of these codes to gain access to your account.',
            BR(), BR(),
            'For example, click the "copy" link to the right and then paste into your password manager entry for this site, or click the "download" link and then move the downloaded file to a secure place in your personal documents.',
            BR(), BR(),
            [sub {
                my($source) = @_;
                my($did_copy_link) = 0;
                my($did_dl_link) = 0;
                return Grid([[
                    Grid([
                        map([$_], @{_codes($source)}),
                    ], {class => 'b_fallback_codes'}),
                    Grid([[
                        Link('copy', '#', {
                            ID => 'copy_codes_link',
                        }),
                    ], [
                        Link('download', [sub {$_A->format_uri_for_download(shift(@_))}], {
                            ID => 'download_codes_link',
                        }),
                    ]], {class => 'b_fallback_code_options'}),
                ]], {class => 'b_fallback_code_list'});
            }],
            BR(),
            InlineJavaScript(Join([
                <<'EOF',
(() => {
    const l = document.getElementById("copy_codes_link");
    if (l) {
        if (navigator.clipboard) {
            l.addEventListener("click", (event) => {
                navigator.clipboard.writeText(
EOF
                JavaScriptString([\&_codes, '\n']),
                <<'EOF',
);
            })
        }
        else {
            console.log("clipboard not available");
            //l.style.display = "none";
        }
    }
    else {
        console.log("copy codes link not found");
    }
})();
EOF
            ])),
        ]),
    ])->SUPER::initialize(@_);
}

sub _codes {
    my($source, $separator) = @_;
    my($codes) = $source->req(qw(Action.MFAFallbackCodeList fallback_code_array))->as_array;
    return $separator ? join($separator, @$codes) : $codes;
}

1;
