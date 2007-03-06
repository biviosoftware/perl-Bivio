# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MotionList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	auth_id => ['Motion.realm_id'],
	primary_key => ['Motion.motion_id'],
	order_by => [qw(
	    Motion.name
	    Motion.status
	)],
        other => [qw(
	    Motion.question
	    Motion.type
	)],
    });
}

1;
