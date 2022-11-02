# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TimeZoneList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_C) = b_use('FacadeComponent.Constant');
my($_R) = b_use('IO.Ref');
my($_TZ) = b_use('Type.TimeZone');

sub display_name_for_enum {
    my($self, $enum) = @_;
    $self->load_all
        unless $self->is_loaded;
    return $self->find_row_by(enum => $enum) ? $self->get('display_name')
        : $enum->as_display_name;
}

sub enum_for_display_name {
    my($self, $display_name) = @_;
    return _get_enum_from_model($self, $display_name)
        || $_TZ->from_any($display_name);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 0,
        $self->field_decl(
            primary_key => [
                [qw(enum TimeZone)],
            ],
            other => [
                [qw(display_name Line)],
            ],
            undef, 'NOT_NULL',
        ),
    });
}

sub internal_load_rows {
    my($self) = @_;
    return $_R->nested_copy(
        $_C->get_value('Model.TimeZoneList.rows', $self->req));
}

sub unsafe_enum_for_display_name {
    my($self, $display_name) = @_;
    return _get_enum_from_model($self, $display_name)
        || $_TZ->unsafe_from_any($display_name);
}

sub _get_enum_from_model {
    my($self, $display_name) = @_;
    $self->load_all
        unless $self->is_loaded;
    return $self->find_row_by(display_name => $display_name)
        ? $self->get('enum') : undef;
}

1;
