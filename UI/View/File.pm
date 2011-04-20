# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::File;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_FCF) = b_use('Model.FileChangeForm');
my($_FCM) = b_use('Type.FileChangeMode');
my($_LOCK) = b_use('Model.RealmFileLock')->if_enabled;

sub delete_permanently_form {
    my($self) = @_;
    return $self->internal_body($self->internal_delete_permanently_form(@_));
}

sub file_change {
    view_put(xhtml_title => Join([
	vs_text('title.FORUM_FILE_CHANGE'),
	' ',
	String([qw(Model.FileChangeForm realm_file path)]),
    ])),
    return shift->internal_body(Join([
	[\&_javascript_field_selector],
	vs_simple_form(FileChangeForm => [
	    If(['Model.FileChangeForm', '->is_folder'],
		Join([
		    _link('Add file', 'UPLOAD'),
		    _link('Add text file', 'TEXT_FILE'),
		    _link('Add subfolder', 'ADD_SUBFOLDER'),
		    If(['!', 'Model.FileChangeForm', '->is_root'],
			_link('Rename folder', 'RENAME')),
		    If(['!', 'Model.FileChangeForm', '->is_root'],
			_link('Move folder', 'MOVE')),
		    If(['!', 'Model.FileChangeForm', '->is_root'],
			_link('Delete', 'DELETE')),
		], String(' - ')),
		Join([
		    _last_updated('FileChangeForm'),
		    String("\n"),
		    Join([
			If(['Model.FileChangeForm', '->is_text_content_type'],
			    _link('Edit contents', 'TEXT_FILE')),
			_link('Replace contents', 'UPLOAD'),
			_link('Rename file', 'RENAME'),
			_link('Move file', 'MOVE'),
			_link('Delete', 'DELETE'),
			_lock(
			    Link('Leave file locked', URI({
				task_id => 'FORUM_FILE_TREE_LIST',
				query => [['Model.FileChangeForm',
				    '->unsafe_get_context'], 'query'],
			    })),
			    Link('Unlock', '#')->put(attributes => [sub {
				my($source) = @_;
				return ' onclick="'
				    . _javascript_form_object()
				    . $source->req('Model.FileChangeForm')
					->get_field_name_for_html('cancel_button')
				    . '.click()"';
			    }]),
			),
		    ], String(' - ')),
		]),
	    ),
	    vs_blank_cell(),
	    FormFieldError('RealmFile.path_lc'),
	    ['FileChangeForm.name', {
		row_class => 'hidden_file_field',
	    }],
	    ['FileChangeForm.rename_name', {
		row_class => 'hidden_file_field',
	    }],
	    ['FileChangeForm.folder_id', {
		row_class => 'hidden_file_field',
		choices => ['Model.RealmFolderList'],
		list_display_field => 'RealmFile.path',
	    }],
	    ['FileChangeForm.file', {
		row_class => 'hidden_file_field',
	    }],
	    ['FileChangeForm.content', {
		row_class => 'hidden_file_field',
		rows => 30,
		cols => 80,
	    }],
	    _lock([
		'FileChangeForm.comment', {
		    row_class => 'hidden_file_field',
		    rows => 2,
		},
	    ]),
	])->put(form_name => 'file_form'),
	"\n" . '<script type="text/javascript">' . "\n",
	[sub {
	     my($source, $mode) = @_;
	     return _javascript_function_name($mode);
	 }, [qw(Model.FileChangeForm mode)]],
	"\n</script>\n",
    ]));
}

sub file_unlock {
    return shift->internal_body(vs_simple_form('FileUnlockForm', [
	DIV_warn(Join([
	    'Override the lock on this file owned by ',
	    String([['Model.RealmFileLock', '->get_model', 'User'],
		'->format_full_name']),
	    '?',
	])),
    ]));
}

sub folder_file_list {
    my($self) = @_;
    vs_put_pager('RealmFolderFileList');
    return $self->tree_list('RealmFolderFileList');
}

sub internal_delete_permanently_form {
    return vs_simple_form('RealmFileDeletePermanentlyForm');
}

sub internal_restore_form {
    return vs_simple_form('RealmFileRestoreForm');
}

sub internal_revert_form {
    return vs_simple_form('RealmFileRevertForm');
}

sub restore_form {
    my($self) = @_;
    return $self->internal_body($self->internal_restore_form(@_));
}

sub revert_form {
    my($self) = @_;
    return $self->internal_body($self->internal_revert_form(@_));
}

sub tree_list {
    my($self, $model) = @_;
    return shift->internal_body(
	If(['Model.' . ($model || 'RealmFileTreeList'), '->can_write'],
	    _tree_list($model),
	    _simple_tree($model),
	),
    );
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
		    _lock(
			If(['->is_locked'],
			    Image(vs_text('RealmFileList.locked_leaf_node')),
			    Image(vs_text('RealmFileList.leaf_node')),
			),
		    ),
		    _file_name(['revision_number']),
		]),
		URI({
		    task_id => 'FORUM_FILE',
		    path_info => ['RealmFile.path'],
		}),
	    ),
	}],
	['RealmFile.modified_date_time', {
	    column_widget => _file_date(),
	}],
	_file_owner_column(),
	_lock('RealmFileLock.comment'),
	vs_file_versions_actions_column(),
#TODO: sorting isn't preserving path_info
    ])->put(want_sorting => 0));
}

sub _file_date {
    return DateTime(['RealmFile.modified_date_time'])
	unless $_LOCK;
    return If(
	['RealmFileLock.modified_date_time'],
	DateTime(['RealmFileLock.modified_date_time']),
	DateTime(['RealmFile.modified_date_time']),
    );
}

sub _file_link_column {
    my($simple) = @_;
    return ['RealmFile.path', {
	column_order_by => ['RealmFile.path_lc'],
	column_widget => If(['is_max_files_per_folder'],
	    vs_text('RealmFileTreeList.more_files'),
	    $simple ? String(['base_name']) : _file_name(['base_name']),
	),
    }];
}

sub _file_name {
    my($name) = @_;
    return String($name)
	unless $_LOCK;
    return Join([
	String($name),
	If(['->is_locked'],
	   SPAN_warn(' (locked)')),
    ]);
}

sub _file_owner_column {
    return [
	'RealmOwner_2.display_name',
	{
	    column_widget => !$_LOCK ? String(['RealmOwner_2.display_name'])
		: If(
		    ['->is_locked'],
		    SPAN_warn(String(['RealmOwner_3.display_name'])),
		    String(['RealmOwner_2.display_name']),
		),
	},
    ];
}

sub _javascript_field_selector {
    my($source) = @_;
    my($res) = "\n<script type=\"text/javascript\">\n";

    foreach my $mode ($_FCM->get_list) {
	next if $mode->eq_unknown;
	my($name) = _javascript_function_name($mode);
	my($visible_names) = [$source->req('Model.FileChangeForm')
	    ->get_fields_for_mode($mode)];
	$res .= "function $name {\n";
	foreach my $field (qw(name rename_name folder_id file comment content)) {
	    next
		if $field eq 'comment' && !$_LOCK;
	    $res .= _javascript_form_object()
		. $source->req('Model.FileChangeForm')
		    ->get_field_name_for_html($field)
		. '.parentNode.parentNode.className = "'
		. (scalar(grep($_ eq $field, @$visible_names))
		    ? 'visible_file_field'
		    : 'hidden_file_field')
		. '";' . "\n";
	}

	foreach my $m ($_FCM->get_list) {
	    next if $m->eq_unknown;
	    my($v) = 
	    $res .= 'try { document.getElementById("'
		. _javascript_link_name($m) . '").style.fontWeight="'
		. ($m eq $mode ? 'bold' : 'normal')
		. '"; } catch(err) {};'
		. "\n";
	}
	# hack to make file browse button render correctly in firefox
	$res .= <<"EOF"
if (navigator.appName == "Netscape")
  @{[_javascript_form_object()]}innerHTML += "\\n";
EOF
	    . _javascript_form_object()
	    . $source->req('Model.FileChangeForm')
		->get_field_name_for_html('mode')
	    . '.value = "' . $mode->to_literal($mode)
	    . '";' . "\nreturn;\n}\n";
    }
    $res .= "\n</script>\n";
    return $res;
}

sub _javascript_form_object {
    return q{document.forms['file_form'].};
}

sub _javascript_function_name {
    my($mode) = @_;
    return 'file_' . lc($mode->get_name) . '()';
}

sub _javascript_link_name {
    my($mode) = @_;
    return 'file_link_' . lc($mode->get_name);
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

sub _link {
    my($text, $mode) = @_;
    return Link($text, '#')->put(attributes =>
	' id="' . _javascript_link_name($_FCM->from_name($mode)) . '"'
	. ' onclick="' . _javascript_function_name($_FCM->from_name($mode))
	. '; return false"');
}

sub _mailto {
    my($form) = @_;
    return vs_mailto_for_user_id(['Model.' . $form, 'realm_file', 'user_id']);
}

sub _simple_tree {
    my($model) = @_;
    return vs_tree_list($model || 'RealmFileTreeList' => [
	_file_link_column(1),
	'RealmFile.modified_date_time',
    ]);
}

sub _tree_list {
    my($model) = @_;
    return vs_tree_list($model || 'RealmFileTreeList' => [
	_file_link_column(),
	['RealmFile.modified_date_time', {
	    column_widget => If(
		And(
		    ['->is_file'],
		    ['!', '->is_archive'],
		),
		Link(_file_date(), URI({
		    task_id => 'FORUM_FILE_VERSIONS_LIST',
		    path_info => ['RealmFile.path'],
		})),
		_file_date(),
	    ),
	}],
	['content_length', {
	    format => 'Bytes',
	    column_data_class => 'amount_cell',
	}],
	_file_owner_column(),
	['actions', {
	    column_data_class => 'list_action',
	    column_widget => ListActions([
		map({
		    [
			vs_text_as_prose("RealmFileTreeList.list_action.$_"),
			$_,
			URI({
			    task_id => $_,
			    path_info => ['RealmFile.path'],
			}),
			$_ eq 'FORUM_FILE_CHANGE' ?
			    And(['!', '->is_archive'],
				['!', 'RealmFile.is_read_only'],
				['!', 'is_max_files_per_folder'])
			: $_ eq 'FORUM_FILE_RESTORE_FORM' ?
			    And(['->is_archive'],
				[sub {
				     my($source) = @_;
				     my($rf) = $source
					 ->get_model('RealmFile');
				     return ! ($rf->get('is_folder')
					 && $rf->new_other('RealmFile')
					     ->set_ephemeral
					     ->unsafe_load({
						 path => $rf->restore_path,
					     }));
				 }])
			: And(['->is_archive'],
			      If(['RealmFile.is_folder'],
				 ['is_empty'],
				 1)),
		    ];
		} qw(
		    FORUM_FILE_CHANGE
		    FORUM_FILE_RESTORE_FORM
		    FORUM_FILE_DELETE_PERMANENTLY_FORM
		)),
	    ]),
	}],
    ]);
}

sub _lock {
    return $_LOCK ? @_ : ();
}

1;
