# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmOwnerBase;
use strict;
use Bivio::Base 'Biz.PropertyModel';
b_use('IO.ClassLoaderAUTOLOAD');

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
	    my($ro) = $self->req(qw(auth_realm owner));
	    foreach my $x (
		$self->cascade_delete_model_list,
	    ) {
		$self->new_other($x->[0])
		    ->do_iterate(
			sub {
			    my($it) = @_;
			    if (Model_RealmOwnerBase()->is_blesser_of($it)) {
				$it->unauth_delete_realm($it->get_primary_id);
			    }
			    else {
				$it->unauth_delete;
			    }
			    return 1;
			},
			'unauth_iterate_start',
			$x->[1],
			{$x->[1] => $pid},
		    );
	    }
	    $self->SUPER::cascade_delete;
	    $self->req->clear_cache_for_auth_realm;
	    $ro->cascade_delete;
	    return;
	},
    );
    return;
}

sub cascade_delete_model_list {
    return (
	[qw(RealmDAG child_id)],
	[qw(RealmDAG parent_id)],
	[qw(RowTag primary_id)],
	[qw(RealmUser realm_id)],
	[qw(RealmUser user_id)],
	[qw(CRMThread realm_id)],
	[qw(Tuple realm_id)],
	[qw(CalendarEvent realm_id)],
	[qw(RealmMail realm_id)],
	[qw(RealmRole realm_id)],
	[qw(MotionVote realm_id)],
	[qw(Motion realm_id)],
	[qw(UserRealmSubscription realm_id)],
	[qw(UserRealmSubscription user_id)],
	[qw(UserDefaultSubscription user_id)],
    );
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

sub internal_initialize_by_realm_type {
    my($self, $info) = @_;
    my($table, $id) = map(lc($self->REALM_TYPE->get_name) . $_, qw(_t _id));
    return $self->merge_initialize_info(
	shift->SUPER::internal_initialize(@_),
	$self->merge_initialize_info(
	    {
		version => 1,
		table_name => $table,
		columns => {
		    $id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
		},
		other => [
		    [$id, qw(RealmOwner.realm_id)],
		],
		auth_id => $id,
	    },
	    $info,
	),
    );
}

sub unauth_delete_realm {
    my($self, $realm_owner_or_id) = @_;
    $self->unauth_load_or_die({
	$self->get_primary_id_name
	    => ref($realm_owner_or_id)
	    ? $realm_owner_or_id->get('realm_id')
	    : $realm_owner_or_id,
    })->cascade_delete;
    return;
}

1;
