# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::RecoveryCode;
use strict;
use Bivio::Base 'Biz.Action';

my($_RC) = b_use('Type.RecoveryCode');
my($_RCL) = b_use('Model.RecoveryCodeList');
my($_RCT) = b_use('Type.RecoveryCodeType');

sub CODE_QUERY_KEY {
    return 'recovery_codes';
}

sub CODE_QUERY_SEPARATOR {
    return ',';
}

sub execute_refill_list {
    my($proto, $req) = @_;
    return 'next'
        unless $req->req('auth_user')->require_totp;
    my($existing_list) = $_RCL->new($req)->load_all({type => $_RCT->TOTP_LOST});
    return 'next'
        if $existing_list->get_result_set_size > $_RCL->get_refill_threshold;
    my($self) = _new($proto, $req);
    _generate_code_array($self);
    $_RCL->create($self->get('recovery_code_array'));
    $existing_list->do_rows(sub {
        my($row) = @_;
        $self->get('recovery_code_array')->append($row->get('RecoveryCode.code'));
        return 1;
    });
    $self->put(is_code_list_update => 1);
    return;
}

sub execute_preview_array {
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
        unless int(@$codes) == $_RCL->get_new_code_count;
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
        task_id => 'USER_RECOVERY_CODE_DOWNLOAD',
        realm => $self->req(qw(auth_user name)),
        query => {
            $self->CODE_QUERY_KEY => join(
                $self->CODE_QUERY_SEPARATOR, $self->req(qw(form_model recovery_codes))->as_list),
        },
    });
}

sub _generate_code_array {
    my($self) = @_;
    $self->put(recovery_code_array => $_RC->generate_new_codes($_RCL->get_new_code_count));
    return $self;
}

sub _new {
    my($proto, $req) = @_;
    return $proto->new->put_on_request($req, 1);
}

1;
