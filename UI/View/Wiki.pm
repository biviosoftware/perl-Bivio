# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Wiki;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;


my($_FP) = b_use('Type.FilePath');

b_use('IO.Config')->register(my $_CFG = {
    use_wysiwyg => 0,
    public_image_folder => $_FP->join(
	$_FP->PUBLIC_FOLDER_ROOT, $_FP->WIKI_DATA_FOLDER),
    private_image_folder => $_FP->WIKI_DATA_FOLDER,
    show_image_upload_tab => 1,
});

sub edit {
    my($self, $view, $form) = @_;
    # shared with View.Blog
    $view ||= $self;
    $form ||= 'WikiForm';
    my($editor) = $_CFG->{use_wysiwyg}
	? \&WYSIWYGEditor
	: \&TextArea;
    my($title_field) = $form =~ /Wiki/ ? 'RealmFile.path_lc' : 'title';
    return $view->internal_body(vs_simple_form($form => [
	_edit_wiki_buttons($form),
	["$form.$title_field", {
	    size => 57,
	}],
	"$form.RealmFile.is_public",
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    $editor->({
		field => 'content',
		id => 'b_wysiwyg_editor',
		@{b_use('UI.Facade')->if_2014style([], [
		    cols => 80,
		    $_CFG->{use_wysiwyg}
			? (
			    rows => 20,
			    _image_folders($self),
			    use_public_image_folder =>
				["Model.$form", 'RealmFile.is_public'],
			) : (
			    rows => 30,
			),
		])},
	    }),
	], b_use('UI.Facade')->if_2014style({edit_col_class => 'col-sm-9'})),
	_edit_wiki_buttons($form),
    ], 1));
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub help {
    view_main(Page({
	xhtml => 1,
	style => view_widget_value('xhtml_style'),
	head => Join([
	    vs_text_as_prose('xhtml_head_title'),
	]),
	body => Join([
	Join([<<"EOF"]),
<script type="text/javascript">
window.onload=function(){
  parent.@{[HelpWiki()->RESIZE_FUNCTION]}();
}
</script>
EOF
	    HelpWiki(1),
	]),
	body_class => 'help_wiki_iframe_body',
    }));
    return;
}

sub not_found {
    return shift->internal_body_prose(<<'EOF');
The page If(['->unsafe_get', 'Action.WikiView'],
Tag(strong => String(['Action.WikiView', 'name']))); was not
found, and you do not have permission to create it.
EOF
}

sub site_view {
    return shift->view(@_);
}

sub validator_all_mail {
    return shift->internal_put_base_attr(
	from => Mailbox(
	    vs_text('support_email'),
	    vs_text_as_prose('support_name'),
	),
	to => Mailbox([qw(Action.WikiValidator to_email)]),
	subject => Prose(vs_text_as_prose('WikiValidator.subject')),
	body => [qw(Action.WikiValidator all_txt)],
    );
}

sub validator_mail {
    return shift->internal_put_base_attr(
	from => Mailbox(
	    vs_text('support_email'),
	    vs_text_as_prose('support_name'),
	),
	to => Mailbox([qw(Action.WikiValidator to_email)]),
	subject => Prose(vs_text_as_prose('WikiValidator.subject')),
	body => b_use('MainErrors.WikiValidator')->error_list_widget(),
    );
}

sub validator_txt {
    my($self) = @_;
    view_class_map('TextWidget');
    view_shortcuts($self->VIEW_SHORTCUTS);
    view_main(SimplePage({
	content_type => 'text/plain',
	value => b_use('MainErrors.WikiValidator')->error_list_widget,
    }));
}

sub version_list {
    my($self) = @_;
    view_put(xhtml_title => vs_text_as_prose('wiki_view_topic'));
    $self->internal_put_base_attr(tools => TaskMenu([
	{
	    task_id => 'FORUM_WIKI_VIEW',
	    label => 'forum_wiki_current',
	    path_info => [qw(Action.WikiView title)],
	},
    ]));
    vs_put_pager('RealmFileVersionsListForm');
    return shift->internal_body(
	vs_list_form(RealmFileVersionsListForm => [
	    map(+{
		column_data_class => 'check',
		column_heading => $_,
		column_widget => Radio($_,
		    [['->get_list_model'], 'RealmFile.realm_file_id'], ''),
		$_ eq 'compare'
		    ? (control => [['->get_list_model'], '->get_cursor']) : (),
	    }, qw(selected compare)),
	    {
		column_widget => Link(
		    Join([
			Image(vs_text('RealmFileList.leaf_node')),
			String([['->get_list_model'], 'revision_number']),
		    ]),
		    URI({
			task_id => 'FORUM_WIKI_VIEW',
			path_info => [['->get_list_model'], 'file_name'],
		    }),
		),
	    },
	    {
		field => 'RealmFile.modified_date_time',
		want_sorting => 0,
	    },
	    {
		field => 'RealmOwner_2.display_name',
	    },
	    b_use('Model.RealmFileLock')->if_enabled(sub {
		return {
		    field => 'RealmFileLock.comment',
		    want_sorting => 0,
		};
	    }),
	    vs_file_versions_actions_column(),
	], {
	    class => 'simple paged_list',
	}),
    );
}

sub versions_diff {
    view_put(
	xhtml_topic => vs_text_as_prose('wiki_diff_topic'),
	xhtml_tools => vs_text_as_prose('wiki_diff_tools'),
    );
    return shift->internal_body(List('RealmFileTextDiffList', [
	If(['line_info'], DIV_different(Join([
	    '*** ',
	    String(['line_info']),
	    ' ***',
	    DIV_top(String(['top'])),
	    DIV_bottom(String(['bottom'])),
	])),
	    DIV_same(String(['same']))),
    ]));
}

sub view {
    return shift->internal_put_base_attr(
	title => vs_text_as_prose('wiki_view_topic'),
	topic => '',
	byline => vs_text_as_prose('wiki_view_byline'),
	tools => vs_text_as_prose('wiki_view_tools'),
	body_class => If(
	    ['UI.Facade', '->auth_realm_is_help_wiki', ['->req']],
	    'b_help_wiki',
	),
	body => Wiki(),
    );
}

sub _edit_wiki_buttons {
    my($form) = @_;
    return StandardSubmit({
	buttons => 'ok_button cancel_button',
    }) unless $form =~ /Wiki/;
    return If(Or(
	['->is_super_user'],
	['->is_substitute_user'],
    ),
        StandardSubmit({
	    buttons => 'ok_no_validate_button ok_button cancel_button',
	}),
        StandardSubmit({
	    buttons => 'ok_button cancel_button',
	}),
    );
}

sub _image_folders {
    return (
	public_image_folder => $_CFG->{public_image_folder},
	private_image_folder => $_CFG->{private_image_folder},
    );
}

1;
