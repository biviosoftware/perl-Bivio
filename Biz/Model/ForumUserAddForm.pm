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
    # ASSUMES: if RealmUser.role set, it is ADMINISTRATOR.  Don't assert,
    # because there may be other administrator or "special" roles
    _down($self)
	if $self->unsafe_get('RealmUser.role');
    _up($self);
    return @res;
}

sub internal_get_roles {
    my($self) = @_;
    return [
	@{$self->SUPER::internal_get_roles(@_)},
	Bivio::Auth::Role->MAIL_RECIPIENT,
    ];
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
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
		role => $self->get('RealmUser.role'),
	    }) ? () : $child->get('forum_id');
	},
	'unauth_iterate_start',
	'forum_id',
	{parent_realm_id => $self->get('RealmUser.realm_id')},
    )}) {
	$self->execute($self->get_request, {
	    map(($_ => $self->get($_)), qw(User.user_id RealmUser.role)),
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
	'RealmUser.role' => undef,
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
