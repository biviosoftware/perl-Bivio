# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UnitTestList;
use strict;
use Bivio::Base 'Model.NumberedList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    {
		name => 'letters',
		type => 'Name',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{letters} = chr($row->{index} + ord('A')) x 2;
    return 1;
}

1;
