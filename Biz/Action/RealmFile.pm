# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmFile;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_DATA_READ)
    = ${__PACKAGE__->use('Auth.PermissionSet')->from_array(['DATA_READ'])};
my($_RF) = __PACKAGE__->use('Model.RealmFile');

sub access_controlled_execute {
    my($proto, $req) = @_;
    my($rf) = $proto->access_controlled_load(
	$req->get('auth_id'),
	$_RF->parse_path($req->get('path_info')),
	$req,
    );
    return $rf ? $proto->set_output_for_get($rf) : 0;
}

sub access_controlled_load {
    my($proto, $realm_id, $path, $req, $no_die) = @_;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    foreach my $is_public (1, 0) {
	last if $rf->unauth_load({
	    path => $is_public ? $_FP->to_public($path) : $path,
	    realm_id => $realm_id,
	    is_public => $is_public,
	});
    }
    my($e) = 'MODEL_NOT_FOUND';
    if ($rf->is_loaded) {
	my($aipo) = $proto->access_is_public_only($req, $realm_id);
	if ($rf->get('is_public') || !$aipo) {
	    return $rf
		unless $rf->get('is_folder');
	    if ($req->unsafe_get_nested(qw(task want_folder_fall_thru))) {
		return undef
		    unless $aipo;
		$e = 'FORBIDDEN';
	    }
	}
	else {
	    $e = 'FORBIDDEN';
	}
    }
    $rf->throw_die($e => {
	entity => $req->get('path_info'),
	realm_id => $req->get('auth_id'),
    }) unless $no_die;
    return undef;
}

sub access_is_public_only {
    my($proto, $req, $realm) = @_;
    my($have_realm) = @_ > 2;
    my($op) = sub {
        return $req->get('auth_realm')
	    ->does_user_have_permissions($_DATA_READ, $req)
	    ? 0 : 1;
    };
    return $have_realm ? $req->with_realm($realm => $op) : $op->();
}

sub execute_private {
    my($proto, $req) = @_;
    return $proto->unauth_execute($req, undef, $req->get('auth_id'));
}

sub execute_public {
    my($proto, $req) = @_;
    $req->put(path_info => $_FP->to_public($req->get('path_info')));
    return $proto->unauth_execute($req, 1, $req->get('auth_id'));
}

sub execute_put {
    my($proto, $req) = @_;
    $req->assert_http_method('put');
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    $rf->create_or_update_with_content(
	{path => $rf->parse_path($req->get('path_info'))},
	$req->get_content,
    );
    return;
}

sub set_output_for_get {
    my(undef, $realm_file) = @_;
    return
	unless $realm_file;
    my($reply) = $realm_file->req->get('reply')
	->set_output($realm_file->get_handle)
	->set_output_type($realm_file->get_content_type);
#TODO: Is this right?
    $reply->set_cache_private
	unless $realm_file->get('is_public');
    return 1;
}

sub unauth_execute {
    my($proto, $req, $is_public, $realm_id, $path_info) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    return $proto->set_output_for_get(
	$f->unauth_load_or_die({
	    realm_id => $realm_id,
	    is_folder => 0,
	    path => $f->parse_path($path_info || $req->get('path_info')),
	    defined($is_public) ? (is_public => $is_public) : (),
	})
    );
}

1;
