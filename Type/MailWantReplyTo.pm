# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailWantReplyTo;
use strict;
use Bivio::Base 'Type.NullBoolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Model.RowTag');

sub get_default {
    return 1;
}

sub is_set_for_realm {
    return shift->row_tag_get_value(@_);
}

sub row_tag_get_value {
    my($self, $req) = @_;
    return $_RT->new($req)->get_value('MAIL_WANT_REPLY_TO') ? 1 : 0;
}

sub row_tag_replace_value {
    my($self, $value, $req) = @_;
    return $_RT->new($req)->replace_value(
	MAIL_WANT_REPLY_TO => $value ? 1 : undef);
}

1;
