# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::SEOPrefix;
use strict;
use Bivio::Base 'Bivio.Cache';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');
my($_RSL) = b_use('Model.RealmSettingList');
my($_BASE) = 'SEOPrefix';
my($_PATH_RE) = _pessimistic_path();
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__);

sub find_prefix_by_uri {
    my($proto, $uri, $req) = @_;
    my($map) = $proto->internal_retrieve($req);
    $uri = _clean($uri);
    while ($uri) {
	if (my $prefix = $map->{$uri}) {
	    return $prefix;
	}
	$uri =~ s{/[^/]*$}{};
    }
    return undef;
}

sub handle_property_model_modification {
    my($proto, $model, $op, $query) = @_;
    return
	unless $model->simple_package_name eq 'RealmFile';
    return
	unless _path_matches_pessimistically($query, $model);
    $model->req->push_txn_resource(
	$proto->new(
	    {realm_id => $query->{realm_id} || $model->get('realm_id')}));
    return;
}

sub internal_compute {
    my($proto, $req) = @_;
    my($res) = $_RSL->new($req)
	->set_ephemeral
	->unauth_get_all_settings(
	    $proto->internal_realm_id($req),
	    $_BASE => [
		[qw(uri Text)],
		[qw(prefix Text)],
	    ],
	);
    return {map(
	(_clean($_->{uri}) => $_->{prefix}),
	values(%$res),
    )};
}

sub internal_realm_id {
    my($proto, $req) = @_;
    return ref($proto) ? $proto->get('realm_id')
	: $_C->get_value('site_realm_id', $req);
}

sub _clean {
    my($uri) = @_;
    $uri = join('/', split(m{/+}, lc($uri)));
    $uri =~ s{^(?=[^/])}{/};
    return $uri;
}

sub _path_matches_pessimistically {
    my($query, $model) = @_;
    return 1
	unless my $p = $query->{path_lc}
	|| $query->{path}
	|| $model->unsafe_get('path_lc');
    return $p =~ $_PATH_RE ? 1 : 0;
}

sub _pessimistic_path {
    return qr{\Q@{[lc(b_use('Type.FilePath')->delete_suffix($_RSL->get_file_path($_BASE)))]}\E}is;
}

1;
