# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::EasyForm;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub update_mail {
    view_put(
	mail_from => Mailbox(vs_text_as_prose('EasyForm.update_mail.from')),
	mail_to => Mailbox(vs_text_as_prose('EasyForm.update_mail.to')),
	mail_subject => vs_text_as_prose('EasyForm.update_mail.subject'),
	mail_body => vs_text_as_prose('EasyForm.update_mail.body'),
    );
    return;
}

1;
