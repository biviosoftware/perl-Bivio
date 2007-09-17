# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmFile;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_DATA_READ) = ${
    __PACKAGE__->use('Bivio::Auth::PermissionSet')->from_array(['DATA_READ'])
};

sub access_controlled_execute {
    my($proto, $req) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    return _execute(
	$proto->access_controlled_load(
	    $req->get('auth_id'),
	    $f->parse_path($req->get('path_info')),
	    $req,
	) || $f->throw_die(MODEL_NOT_FOUND => {
	    entity => $req->get('path_info'),
	    realm_id => $req->get('auth_id'),
	}),
    );
}

sub access_controlled_load {
    my($proto, $realm_id, $path, $req) = @_;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    foreach my $is_public (
	$req->with_realm($realm_id => sub {
	    $req->get('auth_realm')->does_user_have_permissions(
		$_DATA_READ, $req);
	}) ? (0, 1) : 1,
    ) {
	last if $rf->unauth_load({
	    path => $is_public ? $_FP->to_public($path) : $path,
	    realm_id => $realm_id,
	    is_public => $is_public,
	    is_folder => 0,
	});
    }
    return  $rf->is_loaded ? $rf : undef;
}

sub execute {
    my($proto, $req, $is_public) = @_;
    return $proto->unauth_execute($req, $is_public, $req->get('auth_id'));
}

sub execute_public {
    my($proto, $req) = @_;
    $req->put(path_info => $_FP->to_public($req->get('path_info')));
    return $proto->execute($req, 1);
}

sub unauth_execute {
    my($proto, $req, $is_public, $realm_id, $path_info) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    return _execute(
	$f->unauth_load_or_die({
	    realm_id => $realm_id,
	    is_folder => 0,
	    path => $f->parse_path($path_info || $req->get('path_info')),
	    defined($is_public) ? (is_public => $is_public) : (),
	})
    );
}

sub _execute {
    my($realm_file) = @_;
    $realm_file->req->get('reply')->set_output($realm_file->get_handle)
	->set_output_type($realm_file->get_content_type);
    return 1;
}

1;
