# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmOwnerBase;
use strict;
use Bivio::Base 'Biz.PropertyModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');
my($_R) = b_use('Auth.Role');

sub REALM_TYPE {
    my($self) = @_;
    return $_RT->from_name(
	($self->get_primary_id_name =~ /^(\w+)_id$/)[0]
	    || $self->die('invalid primary id name'),
    );
}

sub cascade_delete {
    my($self) = @_;
    my($pid) = $self->get_primary_id;
    $self->req->with_realm(
	$pid,
	sub {
	    foreach my $x (
		[qw(RealmDAG child_id)],
		[qw(RealmDAG parent_id)],
		[qw(RowTag primary_id)],
		[qw(RealmUser realm_id)],
		[qw(RealmUser user_id)],
		[qw(CRMThread realm_id)],
		[qw(RealmMail realm_id)],
		[qw(RealmRole realm_id)],
	    ) {
		$self->new_other($x->[0])
		    ->do_iterate(
			sub {
			    shift->unauth_delete;
			    return 1;
			},
			'unauth_iterate_start',
			$x->[1],
			{$x->[1] => $pid},
		    );
	    }
	    $self->new_other('RealmFile')->delete_all;
	    $self->SUPER::cascade_delete;
	    $self->req(qw(auth_realm owner))->cascade_delete;
	},
    );
    return;
}

sub create_realm {
    my($self, $realm_owner, $admin_id) = @_;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => $self->REALM_TYPE,
	realm_id => $self->get_primary_id,
    });
    $self->new_other('RealmUser')->create({
	realm_id => $self->get_primary_id,
	user_id => $admin_id,
        role => $_R->ADMINISTRATOR,
    }) if $admin_id ||= $self->internal_create_realm_administrator_id;
    return ($self, $ro);
}

sub delete {
    my($self) = @_;
    $self->die('call cascade_delete instead')
	unless $self->my_caller eq 'cascade_delete';
    return shift->SUPER::delete(@_);
}

sub internal_create_realm_administrator_id {
    return;
}

sub unauth_delete_realm {
    my($self, $realm_owner) = @_;
    $self->unauth_load_or_die({
	$self->get_primary_id_name => $realm_owner->get('realm_id'),
    })->cascade_delete;
    return;
}

1;
