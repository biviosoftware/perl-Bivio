# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SEOPrefixSettingList;
use strict;
use Bivio::Base 'Model.RealmSettingList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');

sub find_prefix_by_uri {
    my($self, $uri) = @_;
    my($map) = $self->req->get_if_exists_else_put(
	__PACKAGE__ . '.all',
	sub {
	    my($res) = $self->new_other('RealmSettingList')
		->unauth_get_all_settings(
		    $_C->get_value('site_realm_id', $self->req),
		    SEOPrefix => [
			[qw(uri Text)],
			[qw(prefix Text)],
		    ],
		);
	    return {map(
		(_clean($_->{uri}) => $_->{prefix}),
		values(%$res),
	    )};
	},
    );
    $uri = _clean($uri);
    while ($uri) {
	if (my $prefix = $map->{$uri}) {
	    return $prefix;
	}
	$uri =~ s{/[^/]*$}{};
    }
    return undef;
}

sub _clean {
    my($uri) = @_;
    $uri = join('/', split(m{/+}, lc($uri)));
    $uri =~ s{^(?=[^/])}{/};
    return $uri;
}

1;
