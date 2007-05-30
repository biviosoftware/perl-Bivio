# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Mail::Widget::MailboxList;
use strict;
use Bivio::Base 'MailWidget.List';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_new_args {
    my($proto, $list_class, $attributes) = @_;
    return $proto->SUPER::internal_new_args(
	$list_class,
	[If(['!', '->is_ignore'],
	    Mailbox(['Email.email'], ['RealmOwner.display_name']),
	)],
	{
	    row_separator => ', ',
	    $attributes ? %$attributes : (),
	}
     );
}

1;
