# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiErrorList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => [[qw(path FilePath NOT_NULL)]],
	    other => [
	        'entity',
		'message',
		[qw(line_num Integer)],
	    ],
	    'Text',
	),
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($rows) = $self->[$_IDI];
    $self->[$_IDI] = undef;
    return [
	map({
	    my($row) = $_;
	    +{map(($_ => $row->{$_}), @{$self->get_info('column_names')})};
	} @$rows),
    ];
}

sub load_from_array {
    my($self, $array) = @_;
    $self->[$_IDI] = $array;
    return shift->load_all;
}

1;
