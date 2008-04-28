# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::File;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');

sub file_add {
    _title('FileAddForm', 'Upload file to'),
    return shift->internal_body(vs_simple_form(FileAddForm => [
	'FileAddForm.file',
	'FileAddForm.comment',
    ]));
}

sub file_delete {
    _title('FileDeleteForm', 'Remove');
    return shift->internal_body(vs_simple_form(FileDeleteForm => []));
}

sub file_lock {
    _title('FileLockForm', 'Check out');
    return shift->internal_body(vs_simple_form(FileLockForm => [
	_last_updated('FileLockForm'),
    ]));
}

sub file_rename {
    _title('FileRenameForm', 'Rename');
    return shift->internal_body(vs_simple_form(FileRenameForm => [
	_last_updated('FileRenameForm'),
	'FileRenameForm.name',
    ]));
}

sub file_unlock {
    _title('FileUnlockForm', 'Unlock');
    return shift->internal_body(vs_simple_form(FileUnlockForm => [
 	DIV_prose(Join([
 	    'Checked out by ',
	    _mailto('FileUnlockForm'),
	])),
    ]));
}

sub file_update {
    _title('FileUpdateForm', 'Replace');
    return shift->internal_body(vs_simple_form(FileUpdateForm => [
	_last_updated('FileUpdateForm'),
	'FileUpdateForm.file',
	'FileUpdateForm.comment',
    ]));
}

sub folder_add {
    _title('FolderAddForm', 'Create a subfolder of');
    return shift->internal_body(vs_simple_form(FolderAddForm => [
	'FolderAddForm.name',
    ]));
}

sub text_form {
    return shift->internal_body(vs_simple_form(TextFileForm => [
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    TextArea({
		field => 'content',
		rows => 30,
		cols => 80,
	    }),
	]),
    ]));
}

sub tree_list {
    return shift->internal_body(vs_tree_list(RealmFileTreeList => [
	['RealmFile.path', {
	    column_order_by => ['RealmFile.path_lc'],
	    column_widget => String(['base_name']),
	}],
	'RealmFile.modified_date_time',
	['RealmOwner_2.display_name', {
	    column_widget => MailTo(['Email.email'],
		['RealmOwner_2.display_name']),
	}],
	{
	    column_heading => String('Actions'),
	    column_data_class => 'list_actions',
	    column_widget => ListActions([
		map({
		    my($n, $t, $c) = @$_;
		    [
			$n,
			$t,
			URI({
			    task_id => $t,
			    realm => [['->get_list_model'],
				      'RealmOwner.name'],
			    query => undef,
			    path_info => ['RealmFile.path'],
			}),
			$c,
			[['->get_list_model'], 'RealmOwner.name'],
		    ];
		}
#TODO: don't allow details for archive
		    [Details => 'FORUM_FILE_VERSIONS_LIST' =>
			 And(
			     ['->is_file'],
			     ['!', \&_is_archive],
			 )],
		    [Edit => FORUM_TEXT_FILE_FORM =>
			 And(
			     ['->is_file'],
			     ['->is_text_content_type'],
			    ['!', 'RealmFile.is_read_only'],
			 )],
		    ['Add File', FORUM_FILE_ADD =>
			And(
			    ['->is_folder'],
			    ['!', 'RealmFile.is_read_only'],
			)],
		    ['New Folder', FORUM_FILE_FOLDER_ADD =>
			And(
			    ['->is_folder'],
			    ['!', 'RealmFile.is_read_only'],
			)],
		    [Rename => FORUM_FILE_RENAME =>
			And(
			    ['!', '->is_root'],
			    ['!', 'RealmFile.is_read_only'],
			)],
		    ['Check Out' => FORUM_FILE_LOCK => ['->can_check_out']],
		    ['Check In' => FORUM_FILE_UPDATE => ['->can_check_in']],
		    [Unlock => FORUM_FILE_UNLOCK => ['->can_unlock']],
		    ['Override Unlock' => FORUM_FILE_UNLOCK_OVERRIDE =>
			And(
			    ['lock_user_id'],
			    ['!', '->can_check_in'],
			)],
		    [Delete => FORUM_FILE_DELETE =>
			And(
			    ['!', '->is_root'],
			    ['!', 'RealmFile.is_read_only'],
			)],
		),
	    ]),
	},
    ]));
}

sub version_list {
    my($self) = @_;
    view_put(xhtml_title => Join([
	['path_info'],
    ]));
    $self->internal_put_base_attr(tools => TaskMenu([
	{
	    task_id => 'FORUM_FILE_TREE_LIST',
	    label => String('back to list'),
	},
    ]));
    return shift->internal_body(vs_paged_list(RealmFileVersionsList => [
	['RealmFile.path', {
	    column_order_by => ['RealmFile.path_lc'],
	    column_widget => Link(
		Join([
		    Image(vs_text('leaf_node')),
		    Tag(span => String(
			[['->get_list_model'], 'revision_number']),
			'name'),
		]),
		URI({
		    task_id => 'FORUM_FILE',
		    path_info => ['RealmFile.path'],
		}),
	    ),
	}],
	'RealmFile.modified_date_time',
	['RealmOwner_2.display_name', {
	    column_widget => MailTo(['Email.email'],
		['RealmOwner_2.display_name']),
	}],
	'comment',
#TODO: sorting isn't preserving path_info
    ])->put(want_sorting => 0));
}

sub _is_archive {
    my($source) = @_;
    my($archive_path) = $_FP->VERSIONS_FOLDER;
    return $source->get_list_model->get('RealmFile.path')
	=~ /^$archive_path/ ? 1 : 0;
}

sub _last_updated {
    my($form) = @_;
    return DIV_prose(Join([
	'Last updated by ',
	_mailto($form),
	' on ',
	DateTime(['Model.' . $form, 'realm_file', 'modified_date_time']),
    ]));
}

sub _mailto {
    my($form) = @_;
    return vs_mailto_for_user_id(['Model.' . $form, 'realm_file', 'user_id']);
}

sub _mailto_text {
    my($form, $text) = @_;
    return;
}

sub _title {
    my($form, $title) = @_;
    view_put(xhtml_title => Join([
	$title,
	If(['Model.' . $form, 'realm_file', 'is_folder'],
	    ' folder: ',
	    ' file: '),
	String(['Model.' . $form, 'realm_file', 'path']),
    ]));
    return;
}

1;
