# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::File;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_FCF) = __PACKAGE__->use('Model.FileChangeForm');
my($_FCM) = __PACKAGE__->use('Type.FileChangeMode');

sub file_change {
    _title('FileChangeForm', '');
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
		    If(['Model.FileChangeForm', 'realm_file_lock'], Join([
			DIV_prose(Join([
			    'Locked by ',
			    String([['Model.FileChangeForm', 'realm_file_lock',
			        '->get_model', 'User'], '->format_full_name']),
			    ' on ',
			    DateTime(['Model.FileChangeForm',
				'realm_file_lock', 'modified_date_time']),
			    ' - ',
			    _abort_link(),
			])),
			If(['!', 'Model.FileChangeForm', '->is_lock_owner'],
			    _lock_warning()),
		    ])),
		    String("\n"),
		    Join([
			If(['Model.FileChangeForm', '->is_text_content_type'],
			    _link('Edit contents', 'TEXT_FILE')),
			_link('Replace contents', 'UPLOAD'),
			_link('Rename file', 'RENAME'),
			_link('Move file', 'MOVE'),
			_link('Delete', 'DELETE'),
		    ], String(' - ')),
		]),
	    ),
	    vs_blank_cell(),
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
	    ['FileChangeForm.comment',{
		row_class => 'hidden_file_field',
		rows => 2,
	    }],
	    If(['Model.FileChangeForm', '->is_folder'],
		StandardSubmit([qw(ok_button cancel_button)]),
		StandardSubmit([qw(ok_button cancel_button abort_button)]),
	    ),
	], 1)->put(form_name => 'file_form'),
	"\n" . '<script type="text/javascript">' . "\n",
	[sub {
	     my($source, $mode) = @_;
	     return _javascript_function_name($mode);
	 }, [qw(Model.FileChangeForm mode)]],
	"\n</script>\n",
    ]));
}

sub tree_list {
    my($d) = If(['RealmFileLock.modified_date_time'],
	DateTime(['RealmFileLock.modified_date_time']),
	DateTime(['RealmFile.modified_date_time']),
    );
    return shift->internal_body(vs_tree_list(RealmFileTreeList => [
	['RealmFile.path', {
	    column_order_by => ['RealmFile.path_lc'],
	    column_widget => Join([
		String(['base_name']),
		If(['RealmFileLock.modified_date_time'],
		    String(' (locked)')),
	    ]),
	}],
	['RealmFile.modified_date_time', {
	    column_widget => If(
		And(
		    ['->is_file'],
		    ['!', \&_is_archive],
		),
		Link($d, URI({
		    task_id => 'FORUM_FILE_VERSIONS_LIST',
		    path_info => ['RealmFile.path'],
		})),
		$d,
	    ),
	}],
	{
	    column_heading => 'RealmOwner_2.display_name',
 	    column_widget => If (['RealmOwner_3.display_name'],
		MailTo(['Email_3.email'], ['RealmOwner_3.display_name']),
		MailTo(['Email_2.email'], ['RealmOwner_2.display_name']),
	    ),
	},
	{
	    column_data_class => 'list_actions',
	    column_widget => ListActions([
		map({
		    my($n, $t, $c, $q) = @$_;
		    [
			$n,
			$t,
			URI({
			    task_id => $t,
			    query => $q,
			    path_info => ['RealmFile.path'],
			}),
			$c,
			[['->get_list_model'], 'RealmOwner.name'],
		    ];
		}
		    [Change => FORUM_FILE_CHANGE =>
			 And(
			     ['!', \&_is_archive],
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
	['RealmFile.modified_date_time', {
	    column_widget => If(['RealmFileLock.modified_date_time'],
		DateTime(['RealmFileLock.modified_date_time']),
		DateTime(['RealmFile.modified_date_time']),
	    ),
	}],
	['RealmOwner_2.display_name', {
	    column_widget => If(['RealmFileLock.modified_date_time'],
		MailTo(['Email_3.email'], ['RealmOwner_3.display_name']),
		MailTo(['Email_2.email'], ['RealmOwner_2.display_name']),
	    ),
	}],
	'RealmFileLock.comment',
#TODO: sorting isn't preserving path_info
    ])->put(want_sorting => 0));
}

sub _abort_link {
    return Link('Release lock and abort changes', '#')->put(attributes => [
	sub {
	    my($source) = @_;
	    return ' onclick="document.file_form.'
		. $source->req('Model.FileChangeForm')
		    ->get_field_name_for_html('abort_button')
		. '.click(); return 0;"';
	}]);
}

sub _is_archive {
    my($source) = @_;
    my($archive_path) = $_FP->VERSIONS_FOLDER;
    return $source->get_list_model->get('RealmFile.path')
	=~ /^$archive_path/ ? 1 : 0;
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

	foreach my $field qw(name rename_name folder_id file comment content) {
	    $res .= 'document.file_form.'
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
	$res .= <<'EOF'
if (navigator.appName == "Netscape")
  document.body.innerHTML += "\n";
EOF
	    . 'document.file_form.'
	    . $source->req('Model.FileChangeForm')
		->get_field_name_for_html('mode')
	    . '.value = "' . $mode->to_literal($mode)
	    . '";' . "\nreturn;\n}\n";
    }
    $res .= "\n</script>\n";
    return $res;
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

sub _lock_warning {
    return Join([
	String("\n"),
	DIV_warn(Join([
	    'WARNING: '
	    . ' Any changes made will override the existing lock owned by ',
	    String([['Model.FileChangeForm', 'realm_file_lock',
	        '->get_model', 'User'], '->format_full_name']),
	])),
    ]);
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
