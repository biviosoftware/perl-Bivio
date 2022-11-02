# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Cache::SEOPrefix;
use strict;
use Bivio::Base 'Cache.RealmFileBase';

my($_C) = b_use('FacadeComponent.Constant');
my($_RSL) = b_use('Model.RealmSettingList');
my($_BASE) = 'SEOPrefix';
b_use('Biz.PropertyModel')->register_handler(__PACKAGE__);

sub FILE_PATH_REGEX {
    return qr{\Q@{[lc(b_use('Type.FilePath')->delete_suffix($_RSL->get_file_path($_BASE)))]}\E}is;
}

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
        : $_C->get_value('site_realm_id', $req)
        || shift->SUPER::internal_realm_id(@_);
}

sub _clean {
    my($uri) = @_;
    $uri = join('/', split(m{/+}, lc($uri)));
    $uri =~ s{^(?=[^/])}{/};
    return $uri;
}

1;
