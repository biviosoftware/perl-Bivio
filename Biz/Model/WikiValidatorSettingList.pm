# Copyright (c) 2009-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiValidatorSettingList;
use strict;
use Bivio::Base 'Model.RealmSettingList';

my($_C) = b_use('FacadeComponent.Constant');

sub regexp_for_auth_realm {
    my($self) = @_;
    return undef
	unless my $rid = $_C->get_value('site_reports_realm_id', $self->req);
    my($realm) = $self->req(qw(auth_realm owner_name));
    return $self->req->with_realm(
	$rid,
	sub {
	    return $self->get_setting(
		'WikiValidator',
		$realm,
		'ignore',
		'Regexp',
	    );
	},
    );
}

1;
