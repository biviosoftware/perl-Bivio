# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RowTag;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PI) = b_use('Type.PrimaryId');
my($_RTK) = b_use('Type.RowTagKey');
my($_M) = b_use('Biz.Model');

sub create {
    my($self, $values) = @_;
    return defined($values->{value}) && length($values->{value})
	? shift->SUPER::create(@_)
	: $self;
}

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
	if !exists($values->{value})
	|| defined($values->{value}) && length($values->{value});
    $self->delete;
    return $self;
}

sub _do {
    my($method, $self, $model_or_id, $key, $value) = @_;
    my($id) = _primary_id($self, $model_or_id);
    unless ($id) {
	($key, $value) = ($model_or_id, $key);
	$id = $self->req('auth_id');
    }
    return $self->$method({
	primary_id => $id,
	key => $_RTK->from_any($key),
	$method =~ /load/ ? () : (value => $value),
    });
}

sub _primary_id {
    my($self, $model_or_id) = @_;
    return $model_or_id->get_primary_id
	if $_M->is_blessed($model_or_id);
    return $self->req('auth_id')
	unless defined($model_or_id);
    return $model_or_id
	if $model_or_id =~ /^\d+$/;
    return undef;
}

1;
