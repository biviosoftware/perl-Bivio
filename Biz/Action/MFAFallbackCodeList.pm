# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::MFAFallbackCodeList;
use strict;
use Bivio::Base 'Biz.Action';

my($_MC) = b_use('Type.MnemonicCode');
my($_MFCL) = b_use('Model.MFAFallbackCodeList');
my($_RC) = b_use('Type.RecoveryCode');

sub CODE_QUERY_KEY {
    return 'fallback_codes';
}

sub CODE_QUERY_SEPARATOR {
    return ',';
}

sub execute_refill {
    my($proto, $req) = @_;
    my($res) = {
        method => 'server_redirect',
        task_id => $req->req('Action.UserPasswordQuery') ? 'password_task' : 'next',
        # TODO: need this?
        no_context => 1,
    };
    return $res
        unless $req->req('auth_user')->require_totp;
    my($existing_list) = $_MFCL->new($req)->load_all({type => $_RC->MFA_FALLBACK});
    return $res
        if $existing_list->get_result_set_size > $_MFCL->get_refill_threshold;
    my($self) = _new($proto, $req);
    _generate_code_array($self);
    $_MFCL->create($self->get('fallback_code_array'));
    # TODO: keep or expire existing codes? show them to user?
    $existing_list->do_rows(sub {
        my($row) = @_;
        $self->get('fallback_code_array')->append($row->get('UserRecoveryCode.code'));
        return 1;
    });
    $self->put(is_code_list_update => 1);
    b_debug();
    return;
}

sub execute_preview {
    my($proto, $req) = @_;
    _generate_code_array(_new($proto, $req));
    return;
}

sub execute_download {
    my($proto, $req) = @_;
    b_die('codes not found on query')
        unless my $codes = ($req->unsafe_get('query') || {})->{$proto->CODE_QUERY_KEY};
    $codes = [split($proto->CODE_QUERY_SEPARATOR, $codes)];
    b_die('unexpected code count')
        unless int(@$codes) == $_MFCL->get_new_code_count;
    $req->get('reply')->set_header(
        'Content-Disposition',
        'attachment; filename="recovery-codes.txt"',
    );
    $req->get('reply')->set_output_type('text/plain');
    my($b) = join("\n", @$codes);
    $req->get('reply')->set_output(\$b);
    return 1;
}

sub format_uri_for_download {
    my($self) = @_;
    return $self->req->format_uri({
        task_id => 'USER_MFA_FALLBACK_CODE_DOWNLOAD',
        realm => $self->req(qw(auth_user name)),
        query => {
            $self->CODE_QUERY_KEY => join(
                $self->CODE_QUERY_SEPARATOR, $self->req(qw(form_model fallback_codes))->as_list),
        },
    });
}

sub _generate_code_array {
    my($self) = @_;
    $self->put(fallback_code_array => $_MC->generate_new_codes($_MFCL->get_new_code_count));
    return $self;
}

sub _new {
    my($proto, $req) = @_;
    return $proto->new->put_on_request($req, 1);
}

1;
