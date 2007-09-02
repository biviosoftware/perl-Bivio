# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EasyForm;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub execute {
    my($proto, $req) = @_;
    my($m) = $req->get('r')->method;
    $req->throw_die(CORRUPT_FORM => {
	message => 'must be HTTP POST',
        entity => $m,
    }) unless lc($m) eq 'post';
    my($form, $dir, $rf, $fields, $has_error, $error_msg);
    if (my $die = Bivio::Die->catch(sub {
	# Make sure we really do have a uri for this task, and only
	# get the last part.  This is extra safety so we couldn't possibly
	# write in the wrong folder.
	$dir = ($req->format_uri({query => '', path_info => ''})
		    =~ m{([^/]+)$})[0] . '/';
	$form = _form_fields($req, $dir);
	($rf, $fields) = _csv_fields($req, $dir);
	my($f) = {%$form};
	$rf->append_content(
	    Bivio::Util::CSV->to_csv_text([
		[map(delete($f->{$_}), @$fields)],
	    ]),
	);
	Bivio::Die->die([sort(keys(%$f))], ': unexpected fields submitted')
	    if grep(!/^\&/, keys(%$f));
	return;
    })) {
	$rf ||= Bivio::Biz::Model->new($req, 'RealmFile');
	Bivio::Die->die($dir, ': directory not found: ', $req)
	    unless $dir && $rf->unsafe_load({
		path => $dir,
		is_folder => 1,
	    });
	my($p) = "${dir}Error.log";
	$rf->unsafe_load({path => $p})
	    || $rf->create_with_content({
		path => $p,
		user_id => Bivio::Biz::Model::RealmUser->new
		    ->get_any_online_admin->get('realm_id'),
	    }, \(''));
	my $keys = [sort(keys(%$form))]
	    if $form;
	$error_msg = $dir . $req->get('path_info')
	    . '.csv: failed with error: '
	    . ($die->get('attrs')->{message}
		   || (($die->get('code')->eq_model_not_found
		       ? 'CSV file not found'
		       : $die->get('code')->as_string)
		       . "\n"))
	    . (($form ? ${Bivio::Util::CSV->to_csv_text([
		$keys,
		[map($form->{$_}, @$keys)],
	    ])} : '<no form data>') . "\n");
	$rf->append_content(\($error_msg));
	$has_error = 1;
    }
    my($rn) = $req->get_nested(qw(auth_realm owner name));
    my($fn) = $has_error ? '/Error.log' : $req->get('path_info') . '.csv';
    $req->put(easy_form => Bivio::Collection::Attributes
	->new({
	    mail_to => $rn,
	    file_path => '/' . $rn . '/file/' . (($dir =~ /(.*)\/$/)[0]) . $fn,
	    error => $has_error,
	    error_msg => $error_msg,
	    labels => $fields,
	    values => defined($form) ? {%$form} : {},
	}));
    return {
	uri => $req->get('query')->{goto},
	query => undef,
    };
}

sub _csv_fields {
    my($req, $dir) = @_;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    return (
	$rf->load({path => $dir . $req->get('path_info') . '.csv'}),
	[map(lc($_),
	     @{Bivio::Util::CSV->parse(
		 (${$rf->get_content} =~ /^([^\n]+)/)[0])->[0]})],
    );
}

sub _form_fields {
    my($req, $dir) = @_;
    my($form) = $req->get_form();
    Bivio::Die->die('undefined form submitted')
	unless defined($form);
    $form = {
	map((lc($_) => _to_string(lc($_), $form->{$_}, $dir, $req)),
	    keys(%$form)),
    };
    $form->{'&date'} = Bivio::Type::DateTime->now_as_string;
    $form->{'&client_addr'} = $req->get('client_addr');
    my($e) = Bivio::Biz::Model->new($req, 'Email');
    $form->{'&email'} = $req->get('auth_user')
	&& $e->unauth_load({realm_id => $req->get('auth_user_id')})
	? $e->get('email') : '';
    return $form;
}

sub _to_string {
    my($name, $value, $dir, $req) = @_;
    return $value
	unless ref($value);
    Bivio::Die->die($value, ': unknown reference format')
	unless ref($value) eq 'HASH';
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile')
	->load({path => $dir . $req->get('path_info')});
    Bivio::Die->die($rf->get('path'), ': must be a folder to receive files')
	unless $rf->get('is_folder');
    return ''
	unless defined($_FP->get_clean_tail($value->{filename}));
    return $rf->create_with_content({
	path => $_FP->join(
	    $rf->get('path'),
	    join('-',
		$_DT->now_as_file_name,
	        $name,
		$_FP->get_clean_tail($value->{filename}),
	    ),
	),
	user_id => $req->get('auth_user_id')
	    || Bivio::Biz::Model::RealmUser->new
		    ->get_any_online_admin->get('realm_id'),
    }, $value->{content})->get('path');
}

1;
