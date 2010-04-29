# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache;
use strict;
use Bivio::Base 'Collection.Attributes';
use Storable ();
use IO::File ();
use Fcntl ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IOF) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Bivio.Die');
my($_BF);
my($_REALM_ID) = b_use('Auth.Realm')->get_general->get_default_id;

sub init {
    b_use('IO.ClassLoader')->map_require_all('Cache');
    return;
}

sub handle_commit {
    my($proto, $req) = @_;
    unlink(_file($proto, $req));
    shift->handle_rollback(@_);
    return;
}

sub handle_rollback {
    my($proto, $req) = @_;
    $req->delete(_file($proto, $req));
    return;
}

sub internal_compute_no_cache {
    return undef;
}

sub internal_realm_id {
    return $_REALM_ID;
}

sub internal_retrieve {
    my($proto, $req, @extra) = @_;
    my($fp) = _file($proto, $req);
    return $req->get_if_exists_else_put(
	$fp,
	sub {
	    my($res);
	    return $res
		if $res = -r $fp && Storable::lock_retrieve($fp);
	    my($lfp) = "$fp.flock";
	    my($lock);
	    my($die) = $_D->catch(sub {
		$lock = IO::File->new($lfp, 'w')
		    || b_die($lfp, ": open: $!");
		return $res
		    = $proto->internal_compute_no_cache($req, @extra)
		    unless flock(
			$lock, Fcntl::LOCK_EX() | Fcntl::LOCK_NB());
		return $res = Storable::lock_retrieve($fp)
		    if -r $fp;
		$res = $proto->internal_compute($req, @extra);
		$_IOF->mkdir_parent_only($fp, 0750);
		Storable::lock_store($res, $fp);
		return;
	    });
	    if ($lock) {
		flock($lock, Fcntl::LOCK_UN());
		$lock->close;
	    }
	    $die->throw
		if $die;
	    return $res;
	},
    );
}

sub _file {
    my($proto, $req) = @_;
    return  ($_BF ||= b_use('Biz.File'))->absolute_path(
	$_FP->join(
	    'Cache',
	    $proto->simple_package_name,
	    $proto->internal_realm_id($req),
	),
    );
}

1;
