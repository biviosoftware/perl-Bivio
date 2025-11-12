# Copyright (c) 2025 bivio Software, Inc.  All rights reserved.
package Bivio::UI::HTML::Widget::MFARecoveryCodeList;
use strict;
use Bivio::Base 'XHTMLWidget.Join';
b_use('UI.ViewLanguageAUTOLOAD');

my($_A) = b_use('Action.MFARecoveryCodeList');

sub initialize {
    my($self) = @_;
    return shift->put_unless_exists(values => [
        Join([
            # TODO: probably shouldn't have this text in the widget
            'The following codes are your authenticator recovery codes. If you don\'t have access to your authenticator app you will need to enter one of these codes to gain access to your account.',
            BR(), BR(),
            'Save these codes in a secure place. This list will only be shown to you once.',
            BR(), BR(),
            'For example, click the "copy" link to the right and then paste into your password manager entry for this site, click the "download" link and then move the downloaded file to a secure place where you keep personal files, or click the "print" link and then place the printed page in a secure place in your personal files.',
            BR(), BR(),
            [sub {
                my($source) = @_;
                my($did_copy_link) = 0;
                my($did_dl_link) = 0;
                return Grid([[
                    Grid([
                        map([$_], @{_codes($source)}),
                    ], {class => 'b_mfa_recovery_codes'}),
                    Grid([[
                        Link('copy', '#', {
                            ID => 'copy_codes_link',
                            row_class => 'b_mfa_recovery_code_copy_link',
                        }),
                    ], [
                        Link('download', [sub {$_A->format_uri_for_download(shift(@_))}]),
                    ], [
                        Link('print', '#', {
                            ID => 'print_codes_link',
                        }),
                    ]], {class => 'b_mfa_recovery_code_options'}),
                ]], {class => 'b_mfa_recovery_code_list'});
            }],
            BR(),
            InlineJavaScript(Join([
                <<'EOF',
(() => {
    const l = document.getElementById("copy_codes_link");
    const c = document.getElementsByClassName("b_mfa_recovery_code_copy_link")[0];
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
            if (c) {
                c.style.display = "none";
            }
        }
    }
    else {
        console.log("copy codes link not found");
    }
    function printFrameOnLoad() {
        const closePrintFrame = () => {
            document.body.removeChild(this);
        };
        this.contentWindow.onbeforeunload = closePrintFrame;
        this.contentWindow.onafterprint = closePrintFrame;
        this.contentWindow.print();
    }
    document.getElementById("print_codes_link").addEventListener("click", () => {
        const printFrame = document.createElement("iframe");
        printFrame.onload = printFrameOnLoad;
        printFrame.style.display = "none";
        printFrame.src =
EOF
                '"',
                String([sub {$_A->format_uri_for_print(shift(@_))}]),
                <<'EOF',
";
        document.body.appendChild(printFrame);
    });
})();
EOF
            ])),
        ]),
    ])->SUPER::initialize(@_);
}

sub _codes {
    my($source, $separator) = @_;
    my($codes) = $source->req(qw(Action.MFARecoveryCodeList mfa_recovery_code_array))->as_array;
    return $separator ? join($separator, @$codes) : $codes;
}

1;
