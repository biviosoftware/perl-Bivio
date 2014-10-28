# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::WikiForm;
use strict;
use Bivio::Base 'Model.WikiBaseForm';

my($_WN) = b_use('Type.WikiName');

sub execute_cancel {
    my($self) = @_;
    return {
	task_id => 'next',
	path_info => $self->unsafe_get('file_exists')
	    ? $self->internal_authorized_name
	    : undef,
    };
}

sub execute_empty {
    my($self) = @_;
    return unless _is_edit($self);
    $self->internal_put_field(
	'RealmFile.path_lc' => $self->internal_authorized_name);
    if ($self->get('file_exists')) {
	$self->internal_put_field(
	    content => ${$self->get('realm_file')->get_content},
	);
	$self->internal_put_field(
	    'RealmFile.is_public' => $self->get('realm_file')->get('is_public'),
	);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    _update_file($self);
    return $self->return_with_validate({
	path_info => $self->get('RealmFile.path_lc'),
    });
}

sub execute_other {
    my($self) = @_;
    return if $self->in_error;
    $self->internal_catch_field_constraint_error(
	'RealmFile.path_lc' => sub {
	    _update_file($self);
	    return;
	}
    );
    return if $self->in_error;
    b_use('Action.Acknowledgement')->save_label('FORUM_WIKI_EDIT', $self->req);
    return {
	path_info => $self->get('RealmFile.path_lc'),
    };
}

sub internal_authorized_name {
    # SECURITY: By validating the name, we are sure that we aren't opening
    # up writes in any other directory.
    my($self) = @_;
    my($value, $err) = $self->name_type->from_literal(
	$self->req('path_info') =~ m{^/*(.+)});
    $self->throw_die('NOT_FOUND', {
	message => 'literal error: ' . $err->get_name,
    }) if $err;
    return $value;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    {
		name => 'content',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	    {
		# This is where the constraint is
		name => 'RealmFile.path_lc',
		type => $self->name_type,
	    },
	    {
		name => 'RealmFile.is_public',
		constraint => 'NONE',
	    },
	    {
		name => 'ok_no_validate_button',
		type => 'FormButton',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'realm_file',
		# PropertyModels may act as types.
		type => 'Bivio::Biz::Model::RealmFile',
		constraint => 'NONE',
	    },
	    {
		name => 'file_exists',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(realm_file => $self->new_other('RealmFile'));
    $self->internal_put_field(
	file_exists => _is_edit($self) && _is_loaded($self));
    return;
}

sub name_type {
    return $_WN;
}

sub _is_edit {
    return shift->ureq('path_info') ? 1 : 0;
}

sub _is_loaded {
    my($self) = @_;
    my($rf) = $self->get('realm_file');
    return $rf->unsafe_load({
	path => $self->name_type->to_absolute($self->internal_authorized_name)
    }) || $rf->unsafe_load({
	path => $self->name_type->to_absolute(
	    $self->internal_authorized_name, 1)
    });
}

sub _update_file {
    my($self) = @_;
    my($p) = $self->unsafe_get('RealmFile.is_public') ? 1 : 0;
    my($new) = $self->name_type
	->to_absolute($self->get('RealmFile.path_lc'), $p);
    my($c) = $self->get('content');
    my($m) = $self->get('file_exists')
	? 'update_with_content' : 'create_with_content';
    $self->get('realm_file')->$m({
	path => $new,
	is_public => $p,
    }, \$c);
    return;
}

1;
