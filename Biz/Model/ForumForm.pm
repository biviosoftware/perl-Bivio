# Copyright (c) 2005-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumForm;
use strict;
use Bivio::Base 'Model.RealmFeatureForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FN) = b_use('Type.ForumName');
my($_F) = b_use('UI.Facade');
my($_MODELS) = [qw(Forum RealmOwner)];

sub execute_empty {
    my($self) = @_;
    return _use_general_realm_for_site_admin($self, sub {
        my($req) = $self->get_request;
        return $self->internal_put_field_category_defaults
	    unless _is_forum($req);
        $self->internal_put_field('Forum.forum_id' => $req->get('auth_id'));
	$self->internal_put_categories(1);
        foreach my $m (@$_MODELS) {
            $self->load_from_model_properties($m);
        }
        return
	    unless $self->is_create;
        $self->internal_put_field('RealmOwner.name' =>
            $self->get('RealmOwner.name') . '-');
        $self->internal_put_field('RealmOwner.display_name' =>
            $self->get('RealmOwner.display_name') . ' ');
        return;
    });
}

sub execute_ok {
    my($self) = @_;
    return _use_general_realm_for_site_admin($self, sub {
        unless ($self->unsafe_get('validate_called')) {
            $self->validate;
            return
		if $self->in_error;
        }
        my($req) = $self->get_request;
	$self->internal_put_categories();
        if ($self->is_create) {
            my($f, $ro) = $self->new_other('Forum')->create_realm(
                map($self->get_model_properties($_),
                    @$_MODELS),
            );
            $req->set_realm($ro);
        }
        else {
            foreach my $m (@$_MODELS) {
                $self->update_model_properties($m);
            }
        }
        $self->internal_edit_categories;
        return;
    });
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
	    'Forum.want_reply_to',
	    # Using Booleans instead of proper enum to support WebDAV CSV UI
	    'Forum.require_otp',
	],
	auth_id => ['Forum.forum_id', 'RealmOwner.realm_id'],
	other => [
	    {
		name => 'validate_called',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });
}

sub is_create {
    my($self) = @_;
    my($fm) = $self->req->unsafe_get('Type.FormMode');
    return !$fm || $fm->eq_create;
}

sub validate {
    my($self) = @_;
    return _use_general_realm_for_site_admin($self, sub {
        $self->internal_put_field(validate_called => 1);
        return if $self->get_field_error('RealmOwner.name');
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
            $top_ok ? 'TOP_FORUM_NAME_CHANGE' : 'TOP_FORUM_NAME',
        ) unless $top_ok || $old_top eq $new_top;
        $self->internal_validate_email_modes;
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

sub _use_general_realm_for_site_admin {
    my($self, $op) = @_;
    return $self->req->with_realm(undef, $op)
        if $_F->get_from_source($self)->auth_realm_is_site_admin($self->req);
    return $op->();
}

1;
