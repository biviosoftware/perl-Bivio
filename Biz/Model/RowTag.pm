# Copyright (c) 2007-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RowTag;
use strict;
use Bivio::Base 'Biz.PropertyModel';

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

sub row_tag_get {
    my(undef, $self, $id, $key) = _args(undef, @_);
    my($t) = $key->get_type;
    return $t->get_default
        unless $self->unsafe_load({primary_id => $id, key => $key});
    my($v) = $t->from_sql_column($self->get('value'));
    return $t->is_specified($v) ? $v : $t->get_default;
}

sub row_tag_get_for_auth_user {
    my($self, $key) = @_;
    $key = $_RTK->from_any($key);
    return $key->get_type->get_default
        unless my $uid = $self->ureq('auth_user_id');
    return $self->row_tag_get($uid, $key);
}

sub row_tag_replace {
    my(undef, $self, $id, $key, $value) = _args(undef, @_);
    my($t) = $key->get_type;
    return $self->create_or_update({
        primary_id => $id,
        key => $key,
        value => !$t->is_specified($value)
            || $t->is_equal($value, $t->get_default)
            ? undef
            : $t->to_sql_param($value),
    });
}

sub row_tag_replace_for_auth_user {
    my($self) = shift;
    return
        unless my $uid = $self->ureq('auth_user_id');
    return $self->row_tag_replace($uid, @_);
}

sub update {
    my($self, $values) = @_;
    return shift->SUPER::update(@_)
        if !exists($values->{value})
        || defined($values->{value}) && length($values->{value});
    $self->delete;
    return $self;
}

sub _args {
    my($method, $self, $model_or_id, $key, $value) = @_;
    my($id) = _primary_id($self, $model_or_id);
    unless ($id) {
        ($key, $value) = ($model_or_id, $key);
        $id = $self->req('auth_id');
    }
    return ($method, $self, $id, $_RTK->from_any($key), $value);
}

sub _do {
    my($method, $self, $id, $key, $value) = _args(@_);
    return $self->$method({
        primary_id => $id,
        key => $key,
        $method =~ /load/ ? () : (value => $value),
    });
}

sub _primary_id {
    my($self, $model_or_id) = @_;
    return $model_or_id->get_primary_id
        if $_M->is_blesser_of($model_or_id);
    return $self->req('auth_id')
        unless defined($model_or_id);
    return $model_or_id
        if $model_or_id =~ /^\d+$/;
    return undef;
}

1;
