# Copyright (c) 2025 bivio Software, Inc.  All Rights Reserved.
package Bivio::Biz::Action::MFARecoveryCodeList;
use strict;
use Bivio::Base 'Biz.Action';

my($_AAC) = b_use('Action.AccessChallenge');
my($_MC) = b_use('Type.MnemonicCode');
my($_MRCL) = b_use('Model.MFARecoveryCodeList');
my($_SC) = b_use('Type.AccessCode');
my($_T) = b_use('FacadeComponent.Text');

sub CODE_QUERY_KEY {
    return 'mfa_recovery_codes';
}

sub CODE_QUERY_SEPARATOR {
    return ',';
}

sub execute_refill {
    my($proto, $req) = @_;
    my($next) = $_AAC->get_next($req);
    my($res) = $next ? {
        method => 'server_redirect',
        task_id => $next,
        no_context => 1,
    } : undef;
    my($existing_list) = $_MRCL->new($req)->load_all;
    return $res || 'next'
        unless $existing_list->get_result_set_size < $_MRCL->get_refill_threshold;
    $existing_list->delete;
    $existing_list->create(_generate_code_array(_new($proto, $req)));
    return $res;
}

sub execute_preview {
    my($proto, $req) = @_;
    _generate_code_array(_new($proto, $req));
    return;
}

sub execute_download {
    my($proto, $req) = @_;
    my($codes) = $proto->get_codes_from_query($req);
    b_die('unexpected code count')
        unless int(@$codes) == $_MRCL->get_new_code_count;
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
    my($proto, $source) = @_;
    return _uri($proto, $source, 'USER_MFA_RECOVERY_CODE_LIST_DOWNLOAD');
}

sub format_uri_for_print {
    my($proto, $source) = @_;
    return _uri($proto, $source, 'USER_MFA_RECOVERY_CODE_LIST_PRINT');
}

sub get_codes_from_query {
    my($proto, $source) = @_;
    b_die('codes not found on query')
        unless my $codes = ($source->req->unsafe_get('query') || {})->{$proto->CODE_QUERY_KEY};
    return [split($proto->CODE_QUERY_SEPARATOR, $codes)];
}

sub regenerate_list {
    my($proto, $req) = @_;
    my($l) = $_MRCL->new($req);
    $l->load_all->delete;
    $l->create(_generate_code_array(_new($proto, $req)));
    return;
}

sub _generate_code_array {
    my($self) = @_;
    $self->put(mfa_recovery_code_array => $_MC->generate_new_codes($_MRCL->get_new_code_count));
    return $self->get('mfa_recovery_code_array');
}

sub _new {
    my($proto, $req) = @_;
    return $proto->new->put_on_request($req, 1);
}

sub _uri {
    my($proto, $source, $task_id) = @_;
    return $source->req->format_uri({
        task_id => $task_id,
        realm => $source->req(qw(auth_user name)),
        query => {
            $proto->CODE_QUERY_KEY => join(
                $proto->CODE_QUERY_SEPARATOR, $source->req($proto, 'mfa_recovery_code_array')->as_list),
        },
    });
}

1;
