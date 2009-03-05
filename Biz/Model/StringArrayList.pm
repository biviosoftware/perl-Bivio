# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::StringArrayList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => ['value'],
	    'String',
	),
    });
}

sub internal_load_rows {
    my($self) = @_;
    return $self->[$_IDI]->map_iterate(sub {+{value => shift}});
}

sub load_from_string_array {
    my($self, $string_array) = @_;
    $self->[$_IDI] = $string_array;
    return $self->load_all;
}

1;
