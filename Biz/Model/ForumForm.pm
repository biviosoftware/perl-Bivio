# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumForm;
use strict;
use Bivio::Base 'Model.RealmFeatureForm';

my($_FN) = b_use('Type.ForumName');
my($_R) = b_use('Auth.Realm');

sub REALM_MODELS {
    return [qw(Forum RealmOwner)];
}

sub execute_empty {
    my($self, @args) = @_;
    return $self->internal_use_general_realm_for_site_admin(sub {
        my($req) = $self->get_request;
        return $self->SUPER::execute_empty(@args)
	    unless _is_forum($req);
        $self->internal_put_field('Forum.forum_id' => $req->get('auth_id'));
        foreach my $m (@{$self->REALM_MODELS}) {
            $self->load_from_model_properties($m);
        }
        return $self->SUPER::execute_empty(@args)
	    unless $self->is_create;
        $self->internal_put_field('RealmOwner.name' =>
            $self->get('RealmOwner.name') . '-');
        $self->internal_put_field('RealmOwner.display_name' =>
            $self->get('RealmOwner.display_name') . ' ');
        return $self->SUPER::execute_empty(@args);
    });
}

sub execute_ok {
    my($self, @args) = @_;
    my($realm);
    $self->internal_use_general_realm_for_site_admin(sub {
        my($req) = $self->get_request;
        if ($self->is_create) {
            (undef, $realm) = $self->new_other('Forum')->create_realm(
                map($self->get_model_properties($_),
                    @{$self->REALM_MODELS}),
		$self->internal_admin_user_id,
            );
        }
        else {
            foreach my $m (@{$self->REALM_MODELS}) {
                $self->update_model_properties($m);
            }
	    $realm = $_R->new($self->get_model('RealmOwner'));
        }
	return;
    });
    $self->req->set_realm($realm);
    $self->internal_post_realm_create;
    return shift->SUPER::execute_ok(@_);
}

sub internal_admin_user_id {
    return shift->unsafe_get('admin_user_id');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	require_validate => 1,
        visible => [
	    'RealmOwner.display_name',
	    $self->field_decl([[qw(RealmOwner.name ForumName)]]),
	    'Forum.require_otp',
	],
	other => [
	    $self->field_decl([[qw(admin_user_id User.user_id)]]),
	],
	auth_id => ['Forum.forum_id', 'RealmOwner.realm_id'],
    });
}

sub internal_post_realm_create {
    return;
}

sub is_create {
    my($self) = @_;
    my($fm) = $self->req->unsafe_get('Type.FormMode');
    return !$fm || $fm->eq_create ? 1 : 0;
}

sub validate {
    my($self) = @_;
    return $self->internal_use_general_realm_for_site_admin(sub {
        return
	    if $self->get_field_error('RealmOwner.name');
        # A sub forum must begin with its corresponding root forum prefix, but
        # does not need to prepend its other parent forum names, i.e.:
        # base ---> base-sub1 (valid)
        #  |         |--> base-sub1alpha (valid)
        #  |         |--> base-sub1-beta (also valid)
        #  |--> base-sub2 (valid)
        #  |--> sub3 (INVALID)
        my($req) = $self->get_request;
        my($n) = $self->get('RealmOwner.name');
        my($new_top) = $_FN->extract_top($n);
        return $self->internal_put_error('RealmOwner.name', 'TOP_FORUM_NAME')
            unless $new_top;
        my($old_top, $is_top) = _top($self);
        my($top_ok) = $is_top && $self->is_create && $n eq $new_top;
        return $self->internal_put_error(
            'RealmOwner.name',
            $is_top ? 'TOP_FORUM_NAME' : 'TOP_FORUM_NAME_CHANGE',
        ) unless $top_ok || $old_top eq $new_top;
        return;
    });
}

sub _is_forum {
    return shift->get_nested(qw(auth_realm type))->eq_forum;
}

sub _top {
    my($self) = @_;
    my($req) = $self->get_request;
    return ('', 1)
	unless _is_forum($req);
    my($is_top) = $self->is_create ? 0 : 1;
    my($f) = $self->new_other('Forum')->load;
    foreach my $x (1..10) {
	my($fid) = $f->get('forum_id');
	return (
	    $_FN->extract_top(
		$f->new_other('RealmOwner')
		    ->unauth_load_or_die({realm_id => $fid})->get('name'),
	    ),
	    $is_top,
	) unless $f->unauth_load({forum_id => $f->get('parent_realm_id')});
	$is_top = 0;
    }
    die('too deep');
    # DOES NOT RETURN
}

1;
