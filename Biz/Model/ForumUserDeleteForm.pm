# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserDeleteForm;
use strict;
use base 'Bivio::Biz::Model::RealmUserDeleteForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my(@res) = shift->SUPER::execute_ok(@_);
    _down($self)
	unless $self->in_error || !$self->unsafe_get('User.user_id');
    return @res;
}

sub _down {
    my($self) = @_;
    foreach my $cid (@{$self->new_other('Forum')->map_iterate(
	sub {
	    my($child) = @_;
	    my($not_found) = 1;
	    $self->new_other('RealmUser')->do_iterate(
		sub {$not_found = 0},
		'unauth_iterate_start',
		'role',
		{
		    realm_id => $child->get('forum_id'),
		    user_id => $self->get('User.user_id'),
		},
	    );
	    return $not_found ? () : $child->get('forum_id');
	},
	'unauth_iterate_start',
	'forum_id',
	{parent_realm_id => $self->get('RealmUser.realm_id')},
    )}) {
	$self->execute($self->get_request, {
	    'User.user_id' => $self->get('User.user_id'),
	    'RealmUser.realm_id' => $cid,
	});
    }
    return;
}

1;
