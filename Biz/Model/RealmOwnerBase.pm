# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmOwnerBase;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = __PACKAGE__->use('Auth.RealmType');
my($_R) = __PACKAGE__->use('Auth.Role');

sub REALM_TYPE {
    my($self) = @_;
    return $_RT->from_name(
	($self->get_primary_id_name =~ /^(\w+)_id$/)[0]
	    || $self->die('invalid primary id name'),
    );
}

sub cascade_delete {
    my($self) = @_;
    $self->req->with_realm($self->get_primary_id, sub {
        $self->SUPER::cascade_delete;
	$self->req(qw(auth_realm owner))->cascade_delete;
    });
    return;
}

sub create_realm {
    my($self, $realm_owner) = @_;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => $self->REALM_TYPE,
	realm_id => $self->get_primary_id,
    });
    $self->new_other('RealmUser')->create({
	realm_id => $self->get_primary_id,
	user_id => $self->internal_create_realm_administrator_id,
        role => $_R->ADMINISTRATOR,
    }) if $self->can('internal_create_realm_administrator_id');
    return ($self, $ro);
}

sub delete {
    # this guards against deleting a realm type without also removing the owner
    Bivio::Die->die("call ->cascade_delete instead")
	unless (caller(1))[3] =~ /\:cascade_delete$/;
    return shift->SUPER::delete(@_);
}

sub unauth_delete_realm {
    my($self, $realm_owner) = @_;
    $self->unauth_load_or_die({
	$self->get_primary_id_name => $realm_owner->get('realm_id'),
    })->cascade_delete;
    return;
}

1;
