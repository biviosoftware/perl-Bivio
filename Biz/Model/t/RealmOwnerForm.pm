# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::RealmOwnerForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TTF) = b_use('Model.TupleTagForm');
my($_IDI) = __PACKAGE__->instance_data_index;

sub TUPLE_TAG_IDS {
    return ['b_owner.RealmOwner.realm_id'];
}

sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties($self->req('auth_user'));
    $self->delegate_method($_TTF, @_);
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->update_model_properties('RealmOwner');
    $self->delegate_method($_TTF, @_);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->delegate_method(
        $_TTF,
        $self->merge_initialize_info($self->SUPER::internal_initialize, {
            version => 1,
            visible => [
                'RealmOwner.name',
            ],
            other => $self->TUPLE_TAG_IDS,
        }),
    );
}

sub get_field_info {
    return shift->delegate_method($_TTF, @_);
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field($self->TUPLE_TAG_IDS->[0],
                              $self->req('auth_user_id'));
    return shift->SUPER::internal_pre_execute(@_);
}

sub tuple_tag_form_state {
    return shift->[$_IDI] ||= {};
}

sub tuple_tag_map_slots {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_choice_select_list {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_has_choices {
    return shift->delegate_method($_TTF, @_);
}

sub tuple_tag_slot_label {
    return shift->delegate_method($_TTF, @_);
}

1;
