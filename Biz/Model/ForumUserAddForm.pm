# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserAddForm;
use strict;
use base 'Bivio::Biz::Model::RealmUserAddForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my(@res) = shift->SUPER::execute_ok(@_);
    return @res
	if $self->in_error;
    _down($self)
	if $self->unsafe_get('administrator');
    _up($self);
    return @res;
}

sub internal_get_roles {
    my($self) = @_;
    return [
	@{$self->SUPER::internal_get_roles(@_)},
	$self->unsafe_get('not_mail_recipient') ?
	    () : Bivio::Auth::Role->MAIL_RECIPIENT,
	$self->unsafe_get('administrator') ?
	    Bivio::Auth::Role->ADMINISTRATOR : (),
    ];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	@{$self->internal_initialize_local_fields(
	    visible => [qw(not_mail_recipient administrator)],
	    qw(Boolean NONE))},
        other => [
	    {
		name => 'realm',
		type => 'ForumName',
		constraint => 'NONE',
	    },
	],
    });
}

sub _down {
    my($self) = @_;
    foreach my $cid (@{$self->new_other('Forum')->map_iterate(
	sub {
	    my($child) = @_;
	    return $self->new_other('RealmUser')->unauth_load({
		realm_id => $child->get('forum_id'),
		user_id => $self->get('User.user_id'),
		role => Bivio::Auth::Role->ADMINISTRATOR,
	    }) ? () : $child->get('forum_id');
	},
	'unauth_iterate_start',
	'forum_id',
	{parent_realm_id => $self->get('RealmUser.realm_id')},
    )}) {
	$self->execute($self->get_request, {
	    %{$self->get_shallow_copy},
	    'RealmUser.realm_id' => $cid,
	});
    }
    return;
}

sub _up {
    my($self) = @_;
    my($f) = $self->new_other('Forum')
	->unauth_load_or_die({forum_id => $self->get('RealmUser.realm_id')});
    $self->execute($self->get_request, {
	'User.user_id' => $self->get('User.user_id'),
	# Exclude ADMINISTRATOR (see above)
	'administrator' => 0,
	'RealmUser.realm_id' => $f->get('forum_id'),
    }) if $f->unauth_load({forum_id => $f->get('parent_realm_id')})
	&& !$self->new_other('RealmUser')->unauth_load({
	    realm_id => $f->get('forum_id'),
	    user_id => $self->get('User.user_id'),
	    role => $self->internal_get_roles->[0],
        });
    return;
}

1;
