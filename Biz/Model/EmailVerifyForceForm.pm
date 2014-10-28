# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailVerifyForceForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    $self->new_other('EmailVerify')->force_update($self->get('realm_id'));
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    {
		name => 'realm_id',
		type => 'PrimaryId',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'email',
		type => 'Email',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'display_name',
		type => 'DisplayName',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($rid) = $self->req('query')->{'t'};
    my($e) = $self->new_other('Email')->set_ephemeral;
    $e->unauth_load({realm_id => $rid});
    my($ro) = $self->new_other('RealmOwner')->set_ephemeral;
    $ro->unauth_load({realm_id => $rid});
    $self->internal_put_field(
	realm_id => $rid,
	email => $e->get('email'),
	display_name => $ro->get('display_name'),
    );
    return @res;
}

1;
