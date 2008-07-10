# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Mail;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('MIME.Type');
my($_MF) = __PACKAGE__->use('Model.MailForm');

sub PART_TASK {
    return 'FORUM_MAIL_PART';
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

sub internal_name {
    return shift->simple_package_name;
}

sub internal_part_list {
    my($self) = @_;
    return DIV_parts(
	With(['->get_mail_part_list'],
	     If(['!', '->has_mime_cid'],
		If([sub {$_[1] > 1}, ['index']],
		   DIV_attachment(_thread_list_director($self)),
		   _thread_list_director($self),
	       ),
	    ),
	),
	{id => ['RealmMail.realm_file_id']},
    );
}

sub internal_reply_list {
    return qw(realm all author);
}

sub internal_standard_tools {
    my($self) = @_;
    $self->internal_put_base_attr(tools => TaskMenu([
        {
	    task_id => _name($self, 'FORUM_XX_FORM'),
	    control => ['!', 'task_id', _name($self, '->eq_forum_xx_form')],
	    query => undef,
	},
        {
	    task_id => _name($self, 'FORUM_XX_THREAD_ROOT_LIST'),
	    control => [
		'!',
		'task_id',
		_name($self, '->eq_forum_xx_thread_root_list'),
	    ],
	    query => undef,
	},
    ]));
    return;
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
    my($self, $extra_fields, $buttons) = @_;
    my($cols) = 80;
    $buttons ||= '*';
    return $self->internal_body(
	DIV_msg_compose(Join([
	    vs_simple_form(_name($self, 'XxForm') => [
		@{$extra_fields || [$buttons]},
		map([_name($self, "XxForm.$_"), {
		    cols => $cols,
		    rows => 1,
		    row_class => 'textarea',
		}], qw(to cc)),
		[_name($self, 'XxForm.subject'), {
		    size => $cols + 2,
		}],
		[_name($self, 'XxForm.body'), {
		    rows => 24,
		    cols => $cols,
		    row_class => 'textarea',
		}],
		@{Bivio::Biz::Model->get_instance(_name($self, 'XxForm'))
		    ->map_attachments(sub {
		        return _name($self, 'XxForm.') . shift(@_);
		    })},
		$buttons,
	    ]),
	    If([_name($self, 'Model.XxForm'), '->is_reply'], _msg($self, 1)),
	])),
    );
}

sub thread_list {
    my($self) = @_;
    vs_put_pager(_name($self, 'XxThreadList'));
    return $self->internal_body(_msg($self, 0));
}

sub thread_root_list {
    my($self, @fields) = @_;
    return $self->internal_body(vs_paged_list(
	_name($self, 'XxThreadRootList') => [
	    map({
		my($field, $attrs) = ref($_) ? @$_ : $_;
		$attrs ||= {};
		[$field => {
		    column_widget => Link(
			$field =~ /email/ ? String([$field])
			    : vs_display(
				_name($self, 'XxThreadRootList') . ".$field"),
			['->drilldown_uri'],
		    ),
		    %$attrs,
		}];
	    }
		@fields ? @fields : (
		    ['excerpt', {
			column_heading => '',
			column_widget => Join([
 			    Link(String(['RealmMail.subject']),
 				['->drilldown_uri']),
			    DIV_msg_exerpt(String(['excerpt'])),
			    SPAN_msg_name_and_date(Join([
				'By ', String(['RealmOwner.display_name']),
				' - ',
				DateTime(['RealmFile.modified_date_time']),
				' - ',
			    ])),
			    Link(Join([
				AmountCell(['message_count'])
				    ->put(decimals => 0),
				' message',
				If([sub {
				    my($source, $count) = @_;
				    return $count > 1 ? 1 : 0;
				}, ['message_count']],
				    Join(['s'])),
			    ]), ['->drilldown_uri']),
			]),
		    }],
	        ),
	    ),
	],
    ));
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
		    RoundedBox(
			TaskMenu([
			    map(+{
				task_id => _name($self, 'FORUM_XX_FORM'),
				label =>
				    _name($self, 'FORUM_XX_FORM.reply_') . $_,
				query => $_MF->reply_query($_),
			    }, $self->internal_reply_list),
			    {
				task_id => 'FORUM_FILE',
				label => _name($self, 'FORUM_XX_FORM.view_rfc822'),
				query => undef,
				path_info => ['RealmFile.path'],
			    },
			]),
			{class => 'actions'},
		    ),
		]),
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
	     'text/html' => MailBodyHTML(['->get_body'], $self->PART_TASK),
	     'text/plain' => MailBodyPlain(['->get_body']),
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
