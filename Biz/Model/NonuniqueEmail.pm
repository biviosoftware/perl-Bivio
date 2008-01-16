# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::NonuniqueEmail;
use strict;
use Bivio::Base 'Model.Email';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{email});
    delete($info->{want_bulletin});
    return $self->merge_initialize_info($info, {
        version => 1,
	email => ['Email', 'NONE'],
    });
}

1;
