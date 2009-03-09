# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RemoteCopy;
use strict;
use Bivio::Base 'Action.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RF) = b_use('Model.RealmFile');
my($_D) = b_use('Bivio.Die');
my($_VERSION) = __PACKAGE__ . '#1';
my($_FPA) = b_use('Type.FilePathArray');
my($_S) = b_use('HTML.Scraper');

sub diff_lists {
    my($proto, $remote_copy_list) = @_;
    my($realm) = $remote_copy_list->get('realm');
    my($remote, $err) = $proto->remote_list($remote_copy_list);
    return (undef, $err)
	if $err;
    my($res) = {to_create => [], to_update => [], ignore => []};
    my($local) = $proto->local_list($remote_copy_list);
    foreach my $x (values(%$remote)) {
	my($md5, $path) = @$x;
	my($m) = delete($local->{lc($path)});
	push(@{$res->{
	    !$m ? 'to_create' : $m->[0] eq $md5 ? 'ignore' : 'to_update'
	}}, $path);
    }
    $res->{to_delete} = [map($_->[1], values(%$local))];
    return {map(
	($_ => $_FPA->new($res->{$_})->sort_unique),
	grep(/to_/, keys(%$res)),
    )};
}

sub execute {
    my($proto, $req) = @_;
    my($rf) = $_RF->new($req);
    $rf->load({path => $rf->parse_path($req->get('path_info'))});
    return $proto->set_output_for_get($rf)
	unless $rf->get('is_folder');
    $req->get('reply')->set_output_type('text/plain')
	->set_output(_list($rf))
	->set_cache_private;
    return 1;
}

sub local_list {
    my(undef, $remote_copy_list) = @_;
    my($res) = {};
    $remote_copy_list->get_list_model->get('folder')->do_iterate(sub {
        my($fp) = @_;
	$remote_copy_list->new_other('RealmFileMD5List')->do_iterate(
	    sub {
		my($p, $m) = shift->get(qw(RealmFile.path md5));
		$res->{lc($p)} = [$m, $p];
		return 1;
	    },
	    {path_info => $fp},
	);
    });
    return $res;
}

sub remote_get {
    my($self, $path, $remote_copy_list) = @_;
    my($err);
    my($res) = _get(
	_uri($path, $remote_copy_list), $remote_copy_list, \$err);
    return ($res, $err);
}

sub remote_list {
    my(undef, $remote_copy_list) = @_;
    my($uri) = _uri('PATH', $remote_copy_list);
    my($u);
    my($res) = {};
    my($err);
    $remote_copy_list->get('folder')->do_iterate(sub {
	my($fp) = @_;
	($u = $uri) =~ s{/PATH$}{$fp};
	return 1
	    unless my $r = _get($u, $remote_copy_list, \$err);
	$r = [split(/\n/, $$r)];
	my($version) = shift(@$r) || '';
	unless ($version eq $_VERSION) {
	    $err .= $u . ' -- version mismatch (not a folder?): '
		. substr($version, 0, 80) . "\n";
	    return 1;
	}
	$res = {
	    %$res,
	    map({
		my($m, $p) = split(/\s+/, $_, 2);
		(lc($p) => [$m, $p]);
	    } @$r),
	};
	return 1;
    });
    $u = "$err: $u"
	if $u && $err;
    return ($res, $err);
}

sub _get {
    my($uri, $remote_copy_list, $err) = @_;
    my($res);
    my($s) = $_S->new({
	auth_user => $remote_copy_list->get('user'),
	auth_password => $remote_copy_list->get('pass'),
    });
    my($die) = $_D->catch_quietly(sub {
	$res = $s->http_get($uri);
	return;
    });
    return $s->extract_content($res)
	unless $die;
    $$err .= $s->user_friendly_error_message($die) . "\n";
    return;
}

sub _list {
    my($rf) = @_;
    return \(join("\n",
        $_VERSION,
	@{$rf->new_other('RealmFileMD5List')->map_iterate(
	    sub {join(' ', shift->get(qw(md5 RealmFile.path)))},
	    {path_info => $rf->get('path_lc')},
	)},
    ));
}

sub _uri {
    my($path, $remote_copy_list) = @_;
    return $remote_copy_list->get('uri')
	. $remote_copy_list->req->format_uri({
	    task_id => 'REMOTE_COPY_GET',
	    path_info => $path,
	    realm => $remote_copy_list->get('realm'),
	    query => undef,
	    no_context => 1,
	});
}

1;
