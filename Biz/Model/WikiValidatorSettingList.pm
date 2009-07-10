# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiValidatorSettingList;
use strict;
use Bivio::Base 'Model.RealmSettingList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('FacadeComponent.Constant');

sub regexp_for_auth_realm {
    my($self) = @_;
    my($n) = $self->req(qw(auth_realm owner_name));
    return $self->req->with_realm(
	$_C->get_value('site_reports_realm_id'),
	sub {$self->get_setting('WikiValidator', $n, 'ignore', 'Regexp')},
    );
}

1;
