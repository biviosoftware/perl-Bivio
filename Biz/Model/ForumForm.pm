# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FN) = Bivio::Type->get_instance('ForumName');

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    return unless _is_forum($req);
    my($r) = $req->get('auth_realm');
    $self->load_from_model_properties($r->get('owner'));
    my($u) = $req->get('auth_user');
    $req->set_user(undef);
    $self->internal_put_field(
	is_public => $r->does_user_have_permissions(['MAIL_SEND'], $req),
    );
    $req->set_user($u);
    return unless _is_create($req);
    $self->internal_put_field('RealmOwner.name' =>
	$self->get('RealmOwner.name') . '-');
    $self->internal_put_field('RealmOwner.display_name' =>
        $self->get('RealmOwner.display_name') . ' ');
    return;
}

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    if (_is_create($req)) {
	my($f, $ro) = $self->new_other('Forum')->create_realm(
	    $self->get_model_properties('RealmOwner'),
	);
	$req->set_realm($ro);
    }
    else {
	$self->update_model_properties('RealmOwner');
    }
    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Util::RealmRole')
        ->edit_categories(
	    ($self->unsafe_get('is_public') ? '+' : '-') . 'public_forum',
	);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    'RealmOwner.display_name',
	    {
		name => 'RealmOwner.name',
		type => 'ForumName',
	    },
	    {
		name => 'is_public',
		type => 'Boolean',
		constraint => 'NOT_NULL',
	    },
	],
	auth_id => ['RealmOwner.realm_id', 'Forum.forum_id'],
    });
}

sub validate {
    my($self) = @_;
    return if $self->get_field_error('RealmOwner.name');
    my($req) = $self->get_request;
    my($n) = $self->get('RealmOwner.name');
    my($new_top) = $_FN->extract_top($n);
    return $self->internal_put_error(
	'RealmOwner.name', Bivio::TypeError->TOP_FORUM_NAME
    ) unless $new_top;
    my($old_top, $is_top) = _top($self);
    my($top_ok) = $is_top && _is_create($req) && $n eq $new_top;
    return $self->internal_put_error(
	'RealmOwner.name',
	$top_ok ? Bivio::TypeError->TOP_FORUM_NAME_CHANGE
	    : Bivio::TypeError->TOP_FORUM_NAME
    ) unless $top_ok || $old_top eq $new_top;
    return;
}

sub _is_create {
    my($fm) = shift->unsafe_get('Type.FormMode');
    return !$fm || $fm->eq_create;
}

sub _is_forum {
    return shift->get_nested(qw(auth_realm type))->eq_forum;
}

sub _top {
    my($self, $mode) = @_;
    my($req) = $self->get_request;
    return ('', 1)
	unless _is_forum($req);
    my($is_top) = _is_create($req) ? 0 : 1;
    my($f) = $self->new_other('Forum')->load;
    foreach my $x (1..10) {
	my($fid) = $f->get('forum_id');
	return (
	    $_FN->extract_top(
		$f->new_other('RealmOwner')->load({realm_id => $fid})
		    ->get('name'),
	    ),
	    $is_top,
	) unless $f->unauth_load({forum_id => $f->get('parent_realm_id')});
	$is_top = 0;
    }
    die('too deep');
    # DOES NOT RETURN
}

1;
