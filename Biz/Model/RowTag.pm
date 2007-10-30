# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RowTag;
use strict;
use Bivio::Base 'Bivio::Biz::PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PI) = __PACKAGE__->use('Type.PrimaryId');
my($_RTK) = __PACKAGE__->use('Type.RowTagKey');

sub create_value {
    return _do(create => @_);
}

sub get_value {
    return _do(unsafe_load => @_) ? shift->get('value') : undef;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'row_tag_t',
	columns => {
	    primary_id => ['PrimaryId', 'PRIMARY_KEY'],
	    key => ['RowTagKey', 'PRIMARY_KEY'],
	    value => ['RowTagValue', 'NOT_NULL'],
	},
    });
}

sub replace_value {
    return _do(create_or_update => @_);
}

sub update {
    my($self, $values) = @_;
    return shift->SUPER::update(@_)
	unless exists($values->{value}) && !defined($values->{value});
    $self->delete;
    return $self;
}

sub _do {
    my($method, $self, $model_or_id, $key, $value) = @_;
    return $self->$method({
	primary_id => _primary_id($model_or_id),
	key => $_RTK->from_any($key),
	$method =~ /load/ ? () : (value => $value),
    });
}

sub _primary_id {
    my($model_or_id) = @_;
    return $model_or_id
	unless ref($model_or_id);
    my($pk) = $model_or_id->get_info('primary_key_names');
    Bivio::Die->die($model_or_id, ': must have one field which is primary key')
        unless @$pk == 1;
    Bivio::Die->die($pk->[0], ': type is not a primary id')
        unless $model_or_id->get_field_type($pk->[0])->isa($_PI);
    return $model_or_id->get($pk->[0]);
}

1;
