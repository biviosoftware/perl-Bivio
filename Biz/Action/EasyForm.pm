# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EasyForm;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CSV) = b_use('ShellUtil.CSV');
my($_M) = b_use('Biz.Model');
my($_RI) = b_use('Agent.RequestId');
my($_FCT) = b_use('FacadeComponent.Task');
my($_FP) = b_use('Type.FilePath');
my($_C) = b_use('FacadeComponent.Constant');
my($_DT) = b_use('Type.DateTime');
my($_MT) = b_use('MIME.Type');
my($_V) = b_use('UI.View');

sub execute {
    my($proto, $req) = @_;
    $req->assert_http_method('post');
    $_FCT->assert_uri($req->get('task_id'), $req);
    my($dir) = $_C->get_value('easyform_dir', $req);
    my($rf) = $_M->new($req, 'RealmFile');
    b_die($req->get('path_info'), ': invalid Forms path')
	unless my $base
	= $_FP->get_clean_tail($rf->parse_path($req->get('path_info')));
    my($path) = $_FP->join($dir, "$base.csv");
    my($headings) = _headings($rf, $path);
    my($form) = _form($rf);
    my($d) = ${$rf->get_content};
    my($new_headings) = 0;
    foreach my $k (sort(map($_, keys(%$form)))) {
	next
	    if grep($_ eq $k, @$headings);
	$new_headings = 1;
	push(@$headings, $k);
    }
    $d =~ s{^.*?\n}{_headings_csv($headings)}es
	if $new_headings;
    $d .= ${$_CSV->to_csv_text([[map($form->{$_}, @$headings)]])};
    $rf->update_with_content({user_id => $rf->get('user_id')}, \$d);
    my($email) = _email($rf, $base);
    $proto->new({
	file_path => $rf->get('path'),
	to => $email,
	hash_list => $rf->new_other('HashList')->load_from_hash(
	    $form, $headings),
    })->put_on_request($req);
    $_V->execute('EasyForm->update_mail', $req)
	if $email;
    return {
	uri => $req->get('query')->{goto},
	query => undef,
    };
}

sub _email {
    my($rf, $base) = @_;
    return $rf->new_other('RealmSettingsList')->get_value(
	'EasyForm',
	$base,
	sub {
	    return $rf->new_other('EmailAlias')->format_realm_as_incoming(
		$rf->new_other('RealmOwner')->unauth_load_or_die({
		    realm_id => $_C->get_value('site_contact_realm_id')}),
	    );
	},
    );
}

sub _form {
    my($rf) = @_;
    my($e) = $rf->new_other('Email');
    my($uid) = $rf->req->get('auth_user_id');
    my($form) = $rf->req->get_form || {};
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
