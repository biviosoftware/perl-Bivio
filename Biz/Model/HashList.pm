# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::HashList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => ['key'],
	    other => ['value'],
	    'String',
	),
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return [
	map(+{key => $_, value => $fields->{hash}->{$_}}, @{$fields->{keys}}),
    ];
}

sub load_from_hash {
    my($self, $hash, $keys) = @_;
    $self->[$_IDI] = {hash => $hash, keys => $keys || [sort(keys(%$hash))]};
    return $self->load_all;
}

1;
