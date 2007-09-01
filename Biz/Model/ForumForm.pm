# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FN) = Bivio::Type->get_instance('ForumName');
my($_FEM) = Bivio::Type->get_instance('ForumEmailMode');
my($_RR) = Bivio::IO::ClassLoader
    ->simple_require('Bivio::Biz::Util::RealmRole');

sub CREATE_REALM_MODELS {
    return qw(Forum RealmOwner);
}

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    return unless _is_forum($req);
    $self->internal_put_field('Forum.forum_id' => $req->get('auth_id'));
    foreach my $m ($self->CREATE_REALM_MODELS) {
	$self->load_from_model_properties($m);
    }
    return unless $self->is_create;
    $self->internal_put_field('RealmOwner.name' =>
	$self->get('RealmOwner.name') . '-');
    $self->internal_put_field('RealmOwner.display_name' =>
        $self->get('RealmOwner.display_name') . ' ');
    my($cats) = $_RR->list_enabled_categories();
    foreach my $pc ($_FEM->OPTIONAL_MODES) {
	$self->internal_put_field($pc => grep($_ eq $pc, @$cats) ? 1 : 0);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    unless ($self->unsafe_get('validate_called')) {
	$self->validate;
	return if $self->in_error;
    }
    my($req) = $self->get_request;
    if ($self->is_create) {
	my($f, $ro) = $self->new_other('Forum')->create_realm(
	    map($self->get_model_properties($_),
		$self->CREATE_REALM_MODELS),
	);
	$req->set_realm($ro);
    }
    else {
	foreach my $m ($self->CREATE_REALM_MODELS) {
	    $self->update_model_properties($m);
	}
    }
    $_RR->edit_categories({
	map({
	    $_ => $self->unsafe_get($_);
	} $_FEM->OPTIONAL_MODES)});
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
	    'Forum.want_reply_to',
	    # Using Booleans instead of proper enum to support WebDAV CSV UI
	    map(+{
		name => $_,
		type => 'Boolean',
		constraint => 'NONE',
	    }, $_FEM->OPTIONAL_MODES),
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
    return $self->internal_put_error(
	'RealmOwner.name', Bivio::TypeError->TOP_FORUM_NAME
    ) unless $new_top;
    my($old_top, $is_top) = _top($self);
    my($top_ok) = $is_top && $self->is_create && $n eq $new_top;
    return $self->internal_put_error(
	'RealmOwner.name',
	$top_ok ? Bivio::TypeError->TOP_FORUM_NAME_CHANGE
	    : Bivio::TypeError->TOP_FORUM_NAME
    ) unless $top_ok || $old_top eq $new_top;
    my($x) = [grep($self->unsafe_get($_), $_FEM->OPTIONAL_MODES)];
    $self->internal_put_error($x->[1], Bivio::TypeError->MUTUALLY_EXCLUSIVE)
	if @$x > 1;
    return;
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
