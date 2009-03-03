# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::FileChangeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FCM) = __PACKAGE__->use('Type.FileChangeMode');
my($_FN) = __PACKAGE__->use('Type.FileName');
my($_FP) = Bivio::Type->get_instance('FilePath');
b_use('IO.Config')->register(my $_CFG = {
    require_comment => 0,
});

sub QUERY_KEY {
    return 'mode';
}

sub execute_cancel {
    my($self) = @_;
    _release_lock($self);
    return shift->SUPER::execute_cancel(@_);
}

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(mode => _default_mode($self));
    $self->internal_put_field(folder_id =>
	$self->get('realm_file')->get('folder_id'));
    $self->internal_put_field(rename_name => $_FP->get_tail(
	$self->get('realm_file')->get('path')));
    return if $self->is_folder;
    $self->internal_put_field(content =>
	${$self->get('realm_file')->get_content})
	if $self->is_text_content_type;
    return if $self->get('realm_file_lock');
    $self->internal_put_field(realm_file_lock =>
	$self->new_other('RealmFileLock')->create({
	    realm_file_id => $self->get('realm_file')->get('realm_file_id'),
	}));
    $self->internal_put_field('RealmFileLock.realm_file_lock_id' =>
	$self->get('realm_file_lock')->get('realm_file_lock_id'));
    return;
}

sub execute_ok {
    my($self) = @_;

    if ($self->get('mode')->eq_rename) {
	_release_lock($self);
	my(@parts) = split('/', $self->get('realm_file')->get('path'));
	my($old_name) = pop(@parts);
	my($name) = _rename_file_name($self, $old_name);
	$self->get('realm_file')->update({
	    path => $_FP->join(@parts, $name),
	}) unless $old_name eq $name;
    }
    elsif ($self->get('mode')->eq_move) {
	_release_lock($self);
	return if $self->get('folder_id')
	    eq $self->get('realm_file')->get('folder_id');
	my($new_path) = $self->new_other('RealmFile')->load({
	    realm_file_id => $self->get('folder_id'),
	})->get('path');
	_validate_move_folder($self, $new_path)
	    if $self->is_folder;
	return if $self->in_error;
	$self->get('realm_file')->update({
	    path => $_FP->join($new_path,
		$_FP->get_tail($self->get('realm_file')->get('path'))),
	});
    }
    elsif ($self->is_folder) {

	if ($self->get('mode')->equals_by_name(qw(UPLOAD TEXT_FILE))) {
	    my($name, $content) = $self->get('mode')->eq_upload
		? (_add_file_name($self), $self->get('file')->{content})
		: ($self->get(qw(name content)));
	    return if $self->in_error;
	    my($realm_file_id) = $self->new_other('RealmFile')
		->create_with_content({
		    path => $_FP->join($self->get('realm_file')->get('path'),
			$name),
		}, $content)->get('realm_file_id');
	    $self->new_other('RealmFileLock')->create({
		realm_file_id => $realm_file_id,
		comment => $self->get('comment'),
	    }) if defined($self->get('comment'));
	}
	elsif ($self->get('mode')->eq_add_subfolder) {
	    $self->new_other('RealmFile')->create_folder({
		path => $_FP->join($self->get('realm_file')->get('path'),
		    $self->get('name')),
	    });
	}
	elsif ($self->get('mode')->eq_delete) {
	    $self->get('realm_file')->unauth_delete_deep;
	}
	else {
	    die();
	}
    }
    # file
    elsif ($self->get('mode')->equals_by_name(qw(UPLOAD TEXT_FILE))) {
	_release_lock($self);
	my($realm_file_id) = $self->get('realm_file')->update_with_content({
	    override_is_read_only => 1,
	}, $self->get('mode')->eq_upload
	    ? $self->get('file')->{content}
	    : $self->get('content'))->get('realm_file_id');
	$self->new_other('RealmFileLock')->create({
	    realm_file_id => $realm_file_id,
	    comment => $self->get('comment'),
	}) if defined($self->get('comment'));
    }
    elsif ($self->get('mode')->eq_delete) {
	_release_lock($self);
	$self->get('realm_file')->delete;
    }
    else {
	die();
    }
    return;
}

sub get_fields_for_mode {
    my($self, $mode) = @_;
    my(@fields) = $mode->eq_upload
	? qw(file comment)
	: $mode->eq_text_file
	    ? ($self->is_folder ? 'name' : (), qw(content comment))
	    : $mode->eq_add_subfolder
		? 'name'
		: $mode->eq_rename
		    ? 'rename_name'
		    : $mode->eq_move
			? 'folder_id'
			# delete mode
			: 'comment';
    return $_CFG->{require_comment}
	? @fields
	: grep($_ ne 'comment', @fields);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	require_context => 1,
	visible => [
	    map(+{
		name => $_->[0],
		type => $_->[1],
		constraint => 'NONE',
	    }, (
		[qw(name FileName)],
		[qw(rename_name FileName)],
		[qw(folder_id RealmFile.realm_file_id)],
		[qw(file FileField)],
		[qw(comment RealmFileLock.comment)],
		[qw(content Text64K)],
	    )),
	],
	hidden => [
	    {
		name => 'mode',
		type => 'FileChangeMode',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'RealmFileLock.realm_file_lock_id',
		constraint => 'NONE',
	    },
	],
	other => [
	    # this field gets the EXISTS error, also used for forbidden error
	    'RealmFile.path_lc',
	    {
		name => 'realm_file',
		type => 'Model.RealmFile',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'realm_file_lock',
		type => 'Model.RealmFile',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    $self->internal_put_field(realm_file =>
	$self->new_other('RealmFile')->load({
	    path => $self->req('path_info') || '/',
	}));
    my($lock) = $self->new_other('RealmFileLock');
    $self->internal_put_field(realm_file_lock =>
	$lock->unsafe_load({
	    realm_file_id => $self->get('realm_file')->get('realm_file_id'),
	    comment => undef,
	}) ? $lock : undef);

    if ($self->get('RealmFileLock.realm_file_lock_id')) {
	$self->internal_put_error('RealmFile.path_lc' => 'STALE_FILE_LOCK')
	    unless $self->get('RealmFileLock.realm_file_lock_id')
		eq ($self->get('realm_file_lock')
		    ? $self->get('realm_file_lock')->get('realm_file_lock_id')
		    : '');
    }
    $self->internal_put_field('RealmFileLock.realm_file_lock_id' =>
	$self->get('realm_file_lock')->get('realm_file_lock_id'))
	if $self->get('realm_file_lock');
    return {
	method => 'server_redirect',
	task_id => 'FORUM_FILE_OVERRIDE_LOCK',
    } if $self->get('realm_file_lock') && ! $self->is_lock_owner;
    return;
}

sub is_folder {
    my($self) = @_;
    return $self->get('realm_file')->get('is_folder');
}

sub is_lock_owner {
    my($self) = @_;
    return 0 unless $self->get('realm_file_lock');
    return $self->get('realm_file_lock')->get('user_id')
	eq $self->req('auth_user_id') ? 1 : 0;
}

sub is_root {
    my($self) = @_;
    return $self->get('realm_file')->get('path') eq '/';
}

sub is_text_content_type {
    my($self) = @_;
    return 0 if $self->get('realm_file')->get('is_folder');
    return $self->get('realm_file')->is_text_content_type;
}

sub validate {
    my($self) = @_;

    foreach my $name ($self->get_fields_for_mode($self->get('mode'))) {
	$self->validate_not_null($name);
    }
    return;
}

sub _add_file_name {
    my($self) = @_;
    my($name, $err) = $_FN->from_literal(
	$_FP->get_tail($self->get('file')->{filename}));

    if ($err) {
	$self->internal_put_error(file => $err);
	return;
    }
    $self->internal_put_error(file => 'FILE_NAME')
	unless defined($name);
    return $name;
}

sub _default_mode {
    my($self) = @_;
    my($mode) = $_FCM->unsafe_from_any(
	($self->req('query') || {})->{$self->QUERY_KEY});
    return $mode if $mode;
    return $self->is_text_content_type
	? $_FCM->TEXT_FILE
	: $_FCM->UPLOAD;
}

sub _release_lock {
    my($self) = @_;
    $self->get('realm_file_lock')->delete
	if $self->get('realm_file_lock');
    return;
}

sub _rename_file_name {
    my($self, $old_name) = @_;
    my($suffix) = $_FP->get_suffix($old_name);
    return $self->get('rename_name')
	if $self->is_folder || ! $suffix;
    return $suffix eq $_FP->get_suffix($self->get('rename_name'))
	? $self->get('rename_name')
	: join('.', $self->get('rename_name'), $_FP->get_suffix($old_name));
}

sub _validate_move_folder {
    my($self, $new_path) = @_;
    my($path) = $self->get('realm_file')->get('path');
    $self->internal_put_error(folder_id => 'INVALID_FOLDER')
	if $new_path =~ /^\Q$path/;
    return;
}

1;
