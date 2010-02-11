# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Wiki;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub TEXT_AREA_COLS {
    return 80;
}

sub TEXT_AREA_ROWS {
    return 30;
}

sub HIDE_IS_PUBLIC {
    return 0;
}

sub edit {
    my($self) = @_;
    return $self->internal_body(vs_simple_form(WikiForm => [
	'WikiForm.RealmFile.path_lc',
	$self->HIDE_IS_PUBLIC ? () : 'WikiForm.RealmFile.is_public',
	Join([
	    FormFieldError({
		field => 'content',
		label => 'text',
	    }),
	    TextArea({
		field => 'content',
		rows => $self->TEXT_AREA_ROWS,
		cols => $self->TEXT_AREA_COLS,
	    }),
	]),
    ]));
}

sub help {
    view_main(Page({
# Shouldn't this be xhtml => 1,
# Why can't this be inline?
	xhtml => 1,
	style => view_widget_value('xhtml_style'),
	head => Simple(''),
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
	subject => Prose(vs_text('WikiValidator.subject')),
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
	subject => Prose(vs_text('WikiValidator.subject')),
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
    return shift->internal_body(vs_list_form(RealmFileVersionsListForm => [
	map(+{
	    column_data_class => 'check',
	    column_heading => $_,
	    column_widget => Radio({
		field => $_,
		value => [['->get_list_model'], 'RealmFile.realm_file_id'],
	    }),
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
	{
	    field => 'RealmFileLock.comment',
	    want_sorting => 0,
	},
	'*ok_button',
    ]));
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
    my($self) = shift;
    view_put(
	xhtml_title => vs_text_as_prose('wiki_view_topic'),
	xhtml_topic => '',
	xhtml_byline => vs_text_as_prose('wiki_view_byline'),
	xhtml_tools => vs_text_as_prose('wiki_view_tools'),
    );
    return $self->internal_body(Wiki());
}

1;
