# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmFile;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

sub access_controlled_load {
    my($proto, $realm_id, $path, $req) = @_;
    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
    my($public) = $req->unsafe_get('Type.AccessMode');
    $public = $public ? $public->eq_public : 0;
    foreach my $mode ($public .. 1) {
	last if $rf->unauth_load({
	    path => $mode ? $_FP->to_public($path) : $path,
	    realm_id => $realm_id,
	    is_public => $mode,
	});
    }
    return  $rf->is_loaded ? $rf : undef;
}

sub execute {
    my($self, $req, $is_public) = @_;
    return shift->unauth_execute($req, $is_public, $req->get('auth_id'));
}

sub execute_public {
    my($self, $req) = @_;
    $req->put(path_info => $_FP->to_public($req->get('path_info')));
    return $self->execute($req, 1);
}

sub unauth_execute {
    my($proto, $req, $is_public, $realm_id, $path_info) = @_;
    my($f) = Bivio::Biz::Model->new($req, 'RealmFile');
    $path_info ||= $req->get('path_info');
    $req->get('reply')->set_output(
	$f->unauth_load_or_die({
	    realm_id => $realm_id,
	    is_folder => 0,
	    path_lc => lc($f->parse_path($path_info)),
	    defined($is_public) ? (is_public => $is_public) : (),
	})->get_handle,
    )->set_output_type($f->get_content_type);
    return 1;
}

1;
