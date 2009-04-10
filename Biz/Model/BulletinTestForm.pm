# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BulletinTestForm;
use strict;
use Bivio::Base 'Model.BulletinPublishForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_get_target_email {
    my($self) = @_;
    return $self->get('Email.email');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	visible => [
	    'Email.email',
	],
    });
}

1;
