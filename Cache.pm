# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache;
use strict;
use Bivio::Base 'Collection.Attributes';
use Storable ();
use IO::File ();
use Fcntl ();

my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Bivio.Die');
my($_BF);
my($_REALM_ID) = b_use('Auth.Realm')->get_general->get_default_id;
my($_SU);

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
    return $req->has_keys($fp) ? $req->get($fp)
	: _read_and_thaw($fp, $req) || _try_compute($proto, $fp, $req, \@extra);
}

sub _compute {
    my($proto, $fp, $req, $extra) = @_;
    $_F->mkdir_parent_only($fp, 0750);
    my($res) = $proto->internal_compute($req, @$extra);
    my($tmp) = "$fp.tmp";
    $_F->write($tmp, Storable::nfreeze($res));
    $_F->rename($tmp, $fp);
    $req->put($fp => $res);
    return $res;
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

sub _read_and_thaw {
    my($fp, $req) = @_;
    return
	unless my $file = IO::File->new($fp, 'r');
    my($res) = Storable::thaw(${$_F->read($file)});
    $req->put($fp => $res);
    return $res;

}

sub _try_compute {
    my($proto, $fp, $req, $extra) = @_;
    my($res);
    ($_SU ||= b_use('Bivio.ShellUtil'))->lock_action(
	sub {
	    $res = _read_and_thaw($fp, $req) || _compute($proto, $fp, $req, $extra);
	    return
	},
	$fp,
	1,
    );
    return $res || $proto->internal_compute_no_cache($req, @$extra);
}

1;
