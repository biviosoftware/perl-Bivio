# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::RecoveryCodeList;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');

my($_A) = b_use('Action.RecoveryCode');

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(values => [
        [sub {
            my($source) = @_;
            my($did_copy_link) = 0;
            my($did_dl_link) = 0;
            return Grid([[
                Grid([
                    map([$_], $source->req(qw(Model.UserEnableTOTPForm recovery_codes))->as_list),
                ], {class => 'b_recovery_codes'}),
                Grid([[
                    Link('copy', '#', {
                        ID => 'copy_codes_link',
                    }),
                ], [
                    Link('download', [sub {$_A->format_uri_for_download(shift(@_))}], {
                        ID => 'download_codes_link',
                    }),
                ]], {class => 'b_recovery_code_options'}),
            ]], {class => 'b_recovery_code_list'});
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
    ])->SUPER::initialize(@_);
}

sub _codes {
    my($source, $separator) = @_;
    return join($separator, $source->req(qw(Model.UserEnableTOTPForm recovery_codes))->as_list);
}

1;
