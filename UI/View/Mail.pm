# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Mail;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Email');
my($_M) = b_use('Biz.Model');
my($_MF) = b_use('Model.MailForm');
my($_T) = b_use('MIME.Type');

sub DEFAULT_COLS {
    return 80;
}

sub PART_TASK {
    return 'FORUM_MAIL_PART';
}

sub WANT_BOARD_ONLY_OPTION {
    return 1;
}

sub delete_form {
    my($self) = @_;
    return $self->internal_body($self->internal_delete_form(@_));
}

sub form_imail {
    my($self) = @_;
    return $self->internal_put_base_attr(
	from => [_name($self, 'Model.XxForm'), '->mail_header_from'],
	recipients => [
	    _name($self, 'Model.XxForm'),
	    '->mail_envelope_recipients',
	],
	headers_object => [_name($self, 'Model.XxForm')],
	body => [sub {
	    my($source, $f) = @_;
	    my($req) = $source->req;
	    my($body) = $f->get('body');
	    return MIMEEntity({
		mime_type => 'text/plain',
		mime_data => $body,
		mime_encoding => $_T->suggest_encoding('text/plain', \$body),
		values => $f->map_attachments(sub {
		    return unless my $a = $f->get(shift);
		    return MIMEEntity({
			mime_data => ${$a->{content}},
			mime_filename => $a->{filename},
			mime_type => $a->{content_type},
			mime_disposition => 'inline',
			mime_encoding => $_T->suggest_encoding(
			    $a->{content_type}, $a->{content},
			),
		    });
		}),
	    }),
	}, [_name($self, 'Model.XxForm')]],
    );
}

sub internal_delete_form {
    return vs_simple_form('RealmMailDeleteForm');
}

sub internal_form_model {
    my($self, $req) = @_;
    my($m) = $_M->get_instance(_name($self, 'XxForm'));
    return $req ? $m->from_req($req) : $m;
}

sub internal_name {
    return shift->simple_package_name;
}

sub internal_part_list {
    my($self) = @_;
    return DIV_parts(
	With(['->get_mail_part_list'],
	    If(['->show_as_attachment'],
	        If(['!', '->was_attachment_visited'],
		   DIV_attachment(_thread_list_director($self))
	        ),
	        _thread_list_director($self),
	    ),
	),
	{id => ['->get_message_anchor']},
    );
}

sub internal_reply_links {
    my($self) = @_;
    return RoundedBox(
	TaskMenu([
	    map(+{
		task_id => _name($self, 'FORUM_XX_FORM'),
		label =>
		    _name($self, 'FORUM_XX_FORM.reply_') . $_,
		query => $_MF->reply_query($_),
	    }, $self->internal_reply_list),
	    {
		task_id => 'FORUM_MAIL_SHOW_ORIGINAL_FILE',
		label => _name($self, 'FORUM_XX_FORM.view_rfc822'),
		query => undef,
		path_info => ['RealmFile.path'],
		control => [sub {
		    return b_use('Model.RealmMail')
			->can_view_original(shift->req);
		}],
	    },
	    {
		task_id => 'GROUP_MAIL_DELETE_FORM',
		query => {
		    'ListQuery.this' => ['RealmMail.realm_file_id'],
		},
		control => [sub {
		    my($source) = @_;
		    return ! $source->new_other('CRMThread')->unsafe_load({
			thread_root_id => $source->get_query->get('parent_id'),
		    });
		}],
	    },
	    {
		task_id => 'GROUP_MAIL_TOGGLE_PUBLIC',
		label => If(
		    ['RealmFile.is_public'],
		    vs_text_as_prose('realm_mail_make_private'),
		    vs_text_as_prose('realm_mail_make_public'),
		),
		query => {
		    'ListQuery.this' => ['RealmMail.realm_file_id'],
		},
		control => Or(
		    ['RealmFile.is_public'],
		    [
			b_use('Model.RealmMailPublicForm'),
			'->can_toggle_public',
			['->req'],
		    ],
		),
	    },
	    {
		task_id => 'GROUP_BULLETIN_FORM',
		query => {
		    'ListQuery.this' => ['RealmMail.realm_file_id'],
		},
		control => vs_can_group_bulletin_form(),
	    },
	], {
            class => 'task_menu pagination',
        }),
	'actions',
    );
}

sub internal_reply_list {
    return qw(realm all author);
}

sub internal_send_form {
    my($self, $extra_fields, $buttons) = @_;
    $buttons ||= vs_simple_form_submit();
    return DIV_msg_compose(Join([
	vs_simple_form(_name($self, 'XxForm') => [
	    [vs_blank_cell(), FormFieldError('from_email')],
            $buttons,
	    @{$extra_fields || []},
	    $self->internal_send_form_email_field('to'),
	    $self->internal_send_form_email_field('cc'),
	    $self->WANT_BOARD_ONLY_OPTION
		? _name($self, 'XxForm.board_only')
		: (),
	    $self->internal_subject_body_attachments,
	    $buttons,
	]),
	If([_name($self, 'Model.XxForm'), '->is_reply'], _msg($self, 1)),
    ]));
}


sub internal_send_form_email_field {
    my($self, $field) = @_;
    return [_name($self, "XxForm.$field"), {
	cols => $self->DEFAULT_COLS,
	rows => 1,
	row_class => 'textarea',
    }];
}

sub internal_standard_tools {
    my($self, $extra_tools) = @_;
    my(@tasks) = (
        {
	    task_id => _name($self, 'FORUM_XX_FORM'),
	    control => ['!', 'task_id', _name($self, '->eq_forum_xx_form')],
	    query => undef,
	},
        {
	    task_id => _name($self, 'FORUM_XX_THREAD_ROOT_LIST'),
	    label => _name($self, 'XxThreadList') . '.'
		. _name($self, 'FORUM_XX_THREAD_ROOT_LIST'),
	    control => [
		'!',
		'task_id',
		_name($self, '->eq_forum_xx_thread_root_list'),
	    ],
	    query => undef,
	},
    );
    @tasks = reverse(@tasks)
	if b_use('UI.Facade')->if_2014style;
    $self->internal_put_base_attr(tools => TaskMenu([
	@tasks,
	@{$extra_tools || []},
    ]));
    return;
}

sub internal_subject_body_attachments {
    my($self) = @_;
    return (
	[_name($self, 'XxForm.subject'), {
	    size => $self->DEFAULT_COLS + 2,
	}],
	[_name($self, 'XxForm.body'), {
	    rows => 8,
	    cols => $self->DEFAULT_COLS,
	    row_class => 'textarea',
	}],
	@{Bivio::Biz::Model->get_instance(_name($self, 'XxForm'))
	    ->map_attachments(sub {_name($self, 'XxForm.') . shift(@_)})},
    );
}

sub internal_thread_list {
    my($self) = @_;
    return DIV(Join([
	META({
	    ITEMPROP => 'name',
	    CONTENT => String(['Model.' . _name($self, 'XxThreadList'), '->get_subject']),
	}),
	_msg($self, 0),
    ]), {
	ITEMSCOPE => 'itemscope',
	ITEMTYPE => 'https://schema.org/Article',
    });
}

sub internal_thread_root_list {
    my($self, $columns) = @_;
    my($name) = _name($self, 'XxThreadRootList');
    return vs_paged_list(
	$name,
	$columns || $self->internal_thread_root_list_columns,
	{
	    no_pager => 1,
	    show_headings => $name =~ /Mail/
		? (b_use('UI.Facade')->is_2014style ? 0 : 1)
		: 1,
	},
    );
}

sub internal_thread_root_list_columns {
    return [
	['excerpt', {
	    column_heading => '',
	    column_data_class => 'b_msg_summary',
	    column_widget => DIV(Join([
		Link(
		    String(['RealmMail.subject']),
		    ['->drilldown_uri'],
		   {
		       class => 'b_subject',
		       ITEMPROP => 'name',
		   },
		),
		DIV_b_excerpt(String(['excerpt']), {
		    ITEMPROP => 'description',
		}),
		DIV_byline(Join([
		    SPAN_author(
			String(
			    Or(
				['RealmMail.from_display_name'],
				[
				     sub {
					 my(undef, $v) = @_;
				         return $_E->get_local_part($v);
				     },
				     ['RealmMail.from_email'],
				],
			    ),
			    {escape_html => 1},
			),
			{
			    ITEMPROP => 'creator',
			},
		    ),
		    DIV_date(
			If2014Style(
			    vs_smart_date('RealmFile_2.modified_date_time'),
			    DateTime(['RealmFile_2.modified_date_time']),
			),
		    ),
		    META({
			ITEMPROP => 'dateCreated',
			CONTENT => [
			    $_DT, '->to_xml',
			    ['RealmFile.modified_date_time']],
		    }),
		])),
		Link(
		    Join([
			AmountCell(['message_count'])
			->put(decimals => 0),
			' message',
			If(
			    [sub {
				 my(undef, $count) = @_;
				 return $count > 1 ? 1 : 0;
			    }, ['message_count']],
			    Simple('s'),
			),
		    ]),
		    ['->drilldown_uri'],
		    {class => 'b_count'},
		),
		META({
		    ITEMPROP => 'interactionCount',
		    CONTENT => Join([
			'UserComments:',
			['message_count'],
		    ]),
		}),
	    ]), {
		ITEMSCOPE => 'itemscope',
		ITEMTYPE => 'https://schema.org/Article',
	    }),
	}],
    ];
}

sub internal_want_link_for_list {
    my($self, $field) = @_;
    return $field =~ /date_time|_num\b|subject/ ? 1 : 0;
}

sub pre_compile {
    my($self) = shift;
    my(@res) = $self->SUPER::pre_compile(@_);
#TODO: Remove "base" is deprecated
    return @res
	unless $self->internal_base_type =~ /^(xhtml|base)$/;
    $self->internal_standard_tools;
    return @res;
}

sub send_form {
    my($self) = shift;
    return $self->internal_body($self->internal_send_form(@_));
}

sub thread_list {
    my($self) = @_;
    vs_put_pager(_name($self, 'XxThreadList'));
    return $self->internal_body($self->internal_thread_list);
}

sub thread_root_list {
    my($self) = @_;
    vs_put_pager(_name($self, 'XxThreadRootList'));
    return $self->internal_body($self->internal_thread_root_list);
}

sub unsubscribe_form {
    return shift->internal_body(
	vs_simple_form(MailUnsubscribeForm => [
	    '*ok_button cancel_button all_button',
	]),
    );
}

sub _msg {
    my($self, $msg_only) = @_;
    return WithModel(
	$msg_only ? 'RealmMailList' : _name($self, 'XxThreadList'),
	Join([
	    DIV_msg_sep('', $msg_only ? () : {control =>['->get_cursor']}),
	    DIV_msg(
		$msg_only ? $self->internal_part_list : Join([
		    $self->internal_part_list,
		    $self->internal_reply_links,
		]),
		{
		    ITEMSCOPE => 'itemscope',
		    ITEMTYPE => 'https://schema.org/Comment',
		    ITEMPROP => 'comment',
		},
	    ),
	]),
    );
}

sub _name {
    my($self, $name) = @_;
    my($c) = $self->internal_name;
    $name =~ s{xx}{$name =~ /XX/ ? uc($c) : $name =~ /xx/ ? lc($c) : $c}ie
	|| die($name, ': bad name');
    return $name;
}

sub _thread_list_director {
    my($self) = @_;
    return Director(
	 ['mime_type'],
	 {
	     map(
		("image/$_" => Image(
		    ['->format_uri_for_part', $self->PART_TASK],
		    {class => 'inline'},
		)),
		qw(png jpeg gif),
	     ),
	     'text/html' => MailBodyHTML(
                 OpenGraphProperty(['->get_body'], 'description'),
                 $self->PART_TASK,
             ),
	     'text/plain' => MailBodyPlain(
                 OpenGraphProperty(['->get_body'], 'description'),
             ),
	     'x-message/rfc822-headers' => If(
		 ['index'],
		 vs_text_as_prose('MailPartList.forward'),
		 vs_text_as_prose('MailPartList.byline'),

	     ),
	 },
	 Link(
	     vs_text_as_prose('MailPartList.attachment'),
	     ['->format_uri_for_part', $self->PART_TASK],
	     {class => 'download'},
	 ),
     );
}

1;
