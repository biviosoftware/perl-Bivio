# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::EasyForm;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    my($form, $dir, $rf, $fields);
    if (my $die = Bivio::Die->catch(sub {
	# Make sure we really do have a uri for this task, and only
	# get the last part.  This is extra safety so we couldn't possibly
	# write in the wrong folder.
	$dir = ($req->format_uri({query => '', path_info => ''})
		    =~ m{([^/]+)$})[0] . '/';
	$form = _form_fields($req);
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
	$rf->append_content(
	    \($dir
	    . $req->get('path_info')
	    . '.csv: failed with error: '
	    . ($die->get('attrs')->{message}
		   || (($die->get('code')->eq_model_not_found
		       ? 'CSV file not found'
		       : $die->get('code')->as_string)
		       . "\n"))
	    . ($form ? ${Bivio::Util::CSV->to_csv_text([
		$keys,
		[map($form->{$_}, @$keys)],
	    ])} : '<no form data>')
	  ),
	);
    }
    $req->client_redirect($req->get('query')->{goto});
    return;
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
    my($req) = @_;
    my($form) = $req->get_form();
    $form = {map((lc($_) => $form->{$_}), keys(%$form))};
    $form->{'&date'} = Bivio::Type::DateTime->now_as_string;
    $form->{'&client_addr'} = $req->get('client_addr');
    my($e) = Bivio::Biz::Model->new($req, 'Email');
    $form->{'&email'} = $req->get('auth_user')
	&& $e->unauth_load({realm_id => $req->get('auth_user_id')})
	? $e->get('email') : '';
    return $form;
}

1;
