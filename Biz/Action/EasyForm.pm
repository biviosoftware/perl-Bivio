# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EasyForm;
use strict;
use Bivio::Base 'Biz.Action';

my($_C) = b_use('FacadeComponent.Constant');
my($_CSV) = b_use('ShellUtil.CSV');
my($_DT) = b_use('Type.DateTime');
my($_FCT) = b_use('FacadeComponent.Task');
my($_FP) = b_use('Type.FilePath');
my($_M) = b_use('Biz.Model');
my($_MT) = b_use('MIME.Type');
my($_RI) = b_use('Agent.RequestId');
my($_TA) = b_use('Type.TextArea');
my($_V) = b_use('UI.View');
my($_CONTENT_TYPE_FIELD)= b_use('Biz.FormModel')->CONTENT_TYPE_FIELD;

sub execute {
    my($proto, $req, $base_name, $no_update_mail, $form_param) = @_;
    $req->assert_http_method('post')
        unless $form_param;
    $_FCT->assert_uri($req->get('task_id'), $req);
    my($dir) = $_C->get_value('easyform_dir', $req);
    my($rf) = $_M->new($req, 'RealmFile');
    b_die($base_name, ': invalid Forms path')
        unless $base_name ||= $_FP->get_clean_tail($rf->parse_path($req->get('path_info')));
    my($path) = $_FP->join($dir, "$base_name.csv");
    my($headings) = _headings($rf, $path);
    my($form) = _form($rf, $form_param);
    my($d) = ${$rf->get_content};
    $d .= "\n"
        unless $d =~ /\n$/;
    my($new_headings) = 0;
    foreach my $k (sort(map($_, keys(%$form)))) {
        next
            if grep($_ eq $k, @$headings);
        $new_headings = 1;
        push(@$headings, $k);
    }
    $d =~ s{^.*?\n}{_headings_csv($headings)}es
        if $new_headings;
    my($ref) = $_TA->canonicalize_newlines(\$d);
    $$ref .= ${$_CSV->to_csv_text([[map($form->{$_}, @$headings)]])};
    $rf->update_with_content({user_id => $rf->get('user_id')}, $ref);
    my($email) = _email($rf, $base_name);
    $proto->new({
        file_path => $rf->get('path'),
        to => $email,
        hash_list => $rf->new_other('HashList')->load_from_hash(
            $form, $headings),
    })->put_on_request($req);
    $_V->execute('EasyForm->update_mail', $req)
        if $email && !$no_update_mail;
    return $form_param ? 0 : {
        uri => $req->get('query')->{goto},
        query => undef,
    };
}

sub _email {
    my($rf, $key) = @_;
    return $rf->new_other('RealmSettingList')->get_setting(
        'EasyForm',
        $key,
        'mail',
        'Email',
        sub {
            return $rf->new_other('EmailAlias')->format_realm_as_incoming(
                $rf->new_other('RealmOwner')->unauth_load_or_die({
                    realm_id => $_C->get_value('site_contact_realm_id', $rf->req)}),
            );
        },
    );
}

sub _form {
    my($rf, $form) = @_;
    my($e) = $rf->new_other('Email');
    my($uid) = $rf->req->get('auth_user_id');
    $form ||= {%{$rf->req->get_form}} || {};
    delete($form->{$_CONTENT_TYPE_FIELD});
    return {
        map(_form_value($form, $_, $rf), keys(%$form)),
        '&date' => $_DT->now_as_string,
        '&client_addr' => $rf->req->get('client_addr'),
        '&email' => $e->unauth_load({realm_id => $uid})
            ? $e->get('email') : '',
    };
}

sub _form_value {
    my($form, $name, $rf) = @_;
    my($value) = $form->{$name};
    $name = lc($name);
#TODO: Windows safety is an issue (exe, zip, gif, pif?)
    return ($name => !ref($value) ? $value : $rf->req->format_http({
        task_id => 'FORUM_FILE',
        query => undef,
        path_info => $rf->new->create_with_content({
            user_id => $rf->get('user_id'),
            path => $_FP->join(
                $_FP->delete_suffix($rf->get('path')),
                $_RI->current($rf->req)
                    . '-'
                    . $name
                    . '.'
                    . ($_MT->to_extension($value->{content_type})
                           || $_MT->UNKNOWN_EXTENSION),
            ),
        }, $value->{content})->get('path'),
    }));
}

sub _headings {
    my($rf, $path) = @_;
    return [map(
        lc($_),
        @{$_CSV->parse((${$rf->get_content} =~ /^([^\n]+)/)[0])->[0]},
    )] if $rf->unsafe_load({path => $path});
    $rf->create_with_content(
        {
            user_id => $rf->new_other('RealmUser')
                ->get_any_online_admin->get('realm_id'),
            path => $path,
        },
        \(''),
    );
    return [];
}

sub _headings_csv {
    my($headings) = @_;
    return ${$_CSV->to_csv_text([$headings])};
}

1;
