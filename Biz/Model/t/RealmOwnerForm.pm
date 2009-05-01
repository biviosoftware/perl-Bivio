# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::RealmOwnerForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
b_use('ClassWrapper.TupleTag')->wrap_methods(__PACKAGE__, {
    moniker => 'owner',
    primary_id_field => 'RealmOwner.realm_id',
});


sub execute_empty {
    my($self) = @_;
    $self->load_from_model_properties($self->req('auth_user'));
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->update_model_properties('RealmOwner');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    'RealmOwner.name',
	],
	other => [
	    'RealmOwner.realm_id',
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(
	'RealmOwner.realm_id' => $self->req('auth_user_id'));
    return shift->SUPER::internal_pre_execute(@_);
}

1;
