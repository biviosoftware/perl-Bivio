# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EventEmailSettingList;
use strict;
use Bivio::Base 'Model.RealmSettingList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub event_email_for_auth_realm {
    my($self, $module, $event) = @_;
    return $self->get_setting(
	'EventEmail',
	$event ? "$module/$event" : $module,
	'email',
	'Email',
	sub {$self->new_other('EmailAlias')->format_realm_as_incoming},
    );
}

1;
