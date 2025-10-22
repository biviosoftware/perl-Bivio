# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::MFARecoveryCodeList;
use strict;
use Bivio::Base 'Biz.Action';

my($_MC) = b_use('Type.MnemonicCode');
my($_MFCL) = b_use('Model.MFARecoveryCodeList');
my($_SC) = b_use('Type.SecretCode');
my($_T) = b_use('FacadeComponent.Text');
my($_USC) = b_use('Model.UserSecretCode');

sub CODE_QUERY_KEY {
    return 'mfa_recovery_codes';
}

sub CODE_QUERY_SEPARATOR {
    return ',';
}

sub execute_refill {
    my($proto, $req) = @_;
    my($res) = {
        method => 'server_redirect',
        task_id => $req->ureq('Action.UserPasswordQuery') ? 'password_task' : 'next',
        no_context => 1,
    };
    my($existing_list) = $_MFCL->new($req)->load_all({type => $_SC->MFA_RECOVERY});
    return $res
        unless $existing_list->get_result_set_size < $_MFCL->get_refill_threshold;
    $existing_list->do_rows(sub {
        my($row) = @_;
        $_USC->new($req)->load({
            user_secret_code_id => $row->get('UserSecretCode.user_secret_code_id'),
        })->delete;
        return 1;
    });
    my($self) = _new($proto, $req);
    $_MFCL->create(_generate_code_array($self));
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
        'attachment; filename="'
            . join('-', $_T->get_widget_value('site_name', $req) || (), qw(recovery codes))
            . '.txt"',
    );
    $req->get('reply')->set_output_type('text/plain');
    my($b) = join("\n", @$codes);
    $req->get('reply')->set_output(\$b);
    return 1;
}

sub format_uri_for_download {
    my($proto) = @_;
    return $proto->req->format_uri({
        task_id => 'USER_MFA_RECOVERY_CODE_DOWNLOAD',
        realm => $proto->req(qw(auth_user name)),
        query => {
            $proto->CODE_QUERY_KEY => join(
                $proto->CODE_QUERY_SEPARATOR, $proto->req($proto, 'mfa_recovery_code_array')->as_list),
        },
    });
}

sub _generate_code_array {
    my($self) = @_;
    $self->put(mfa_recovery_code_array => $_MC->generate_new_codes($_MFCL->get_new_code_count));
    return $self->get('mfa_recovery_code_array');
}

sub _new {
    my($proto, $req) = @_;
    return $proto->new->put_on_request($req, 1);
}

1;
