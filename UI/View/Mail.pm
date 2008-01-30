# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Mail;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
