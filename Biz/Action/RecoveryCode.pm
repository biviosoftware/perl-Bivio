# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::RecoveryCode;
use strict;
use Bivio::Base 'Biz.Action';

my($_RCL) = b_use('Model.RecoveryCodeList');

sub CODE_QUERY_KEY {
    return 'recovery_codes';
}

sub CODE_QUERY_SEPARATOR {
    return ',';
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
        realm => b_debug($self->req(qw(auth_user name))),
        query => {
            $self->CODE_QUERY_KEY => join(
                $self->CODE_QUERY_SEPARATOR, $self->req(qw(form_model recovery_codes))->as_list),
        },
    });
}

1;
