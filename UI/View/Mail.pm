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
		     Director(
			 ['mime_type'],
			 {
			     'x-message/rfc822-headers' => If(
				 ['index'],
				 DIV_forward(vs_text_as_prose('MailPartList.forward')),
				 DIV_byline(vs_text_as_prose('MailPartList.byline')),
			     ),
			     'text/plain' => DIV_text_plain(String(['->get_body'])),
			     map(
				("image/$_" => Image(
				    ['->format_uri_for_part', 'FORUM_MAIL_PART'],
				)),
				qw(png jpeg gif),
			     ),
			     'text/html' => DIV_text_html(['->get_body']),
			 },
			 Link(
			     DIV_attachment(vs_text_as_prose('MailPartList.attachment')),
			     ['->format_uri_for_part', 'FORUM_MAIL_PART'],
			 ),
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

1;
