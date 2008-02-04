# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Mail;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('MIME.Type');

sub form_mail {
    return shift->internal_put_base_attr(
	from => ['Model.MailForm', '->mail_header_from'],
	recipients => ['Model.MailForm', '->mail_envelope_recipients'],
	headers_object => ['Model.MailForm'],
	body => [sub {
	    my($req, $f) = @_;
	    my($body) = $f->get('body');
	    return MIMEEntity({
		mime_type => 'text/plain',
		mime_data => $body,
		mime_encoding => $_T->suggest_encoding('text/plain', \$body),
		values => [
		    $f->map_attachments(sub {
			return unless my $a = $f->get(shift);
			return {
			    mime_data => $a->{content},
			    mime_filename => $a->{filename},
			    mime_type => $a->{content_type},
			    mime_disposition => 'inline',
			    mime_encoding => $_T->suggest_encoding(
				$a->{content_type}, $a->{content},
			    ),
			};
		    }),
		],
	    }),
	}, ['Model.MailForm']],
    );
}

sub pre_compile {
    my($self) = shift;
    my(@res) = $self->SUPER::pre_compile(@_);
#TODO: Remove "base" is deprecated
    return @res
	unless $self->internal_base_type =~ /^(xhtml|base)$/;
    $self->internal_put_base_attr(tools => TaskMenu([
        {
	    task_id => 'FORUM_MAIL_FORM',
	    control => ['!', 'task_id', '->eq_forum_mail_form'],
	    query => undef,
	},
    ]));
    return @res;
}

sub send_form {
    return shift->internal_body(vs_simple_form(MailForm => [qw(
        MailForm.subject
	MailForm.body
    )]));
}

sub thread_list {
    vs_put_pager('MailThreadList');
    return shift->internal_body(WithModel('MailThreadList',
	Join([
	    DIV_msg_sep('', {control =>['->get_cursor']}),
	    DIV_msg(
		With(['->get_mail_part_list'],
		     If(['!', '->has_mime_cid'],
			_thread_list_director(),
		     ),
		),
	    ),
	]),
    ));
}

sub thread_root_list {
    return shift->internal_body(vs_paged_list(
	MailThreadRootList => [
	    map([$_ => {
		column_widget => Link(
		    /date_time/ ? DateTime([$_]) : String([$_]),
		    ['->drilldown_uri'],
		),
		/subject/ ? (order_by_names => [qw(RealmMail.subject_lc)]) : (),
	    }],
		'RealmFile.modified_date_time',
		'RealmMail.subject',
	    ),
	],
    ));
}

sub _thread_list_director {
    return Director(
	 ['mime_type'],
	 {
	     map(
		("image/$_" => Image(
		    ['->format_uri_for_part', 'FORUM_MAIL_PART'],
		    {class => 'inline'},
		)),
		qw(png jpeg gif),
	     ),
	     'text/html' => MailBodyHTML(['->get_body'], 'FORUM_MAIL_PART'),
	     'text/plain' => MailBodyPlain(['->get_body']),
	     'x-message/rfc822-headers' => If(
		 ['index'],
		 vs_text_as_prose('MailPartList.forward'),
		 vs_text_as_prose('MailPartList.byline'),

	     ),
	 },
	 Link(
	     DIV_attachment(vs_text_as_prose('MailPartList.attachment')),
	     ['->format_uri_for_part', 'FORUM_MAIL_PART'],
	 ),
     );
}

1;
