# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailWantReplyTo;
use strict;
use Bivio::Base 'Type.Boolean';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Model.RowTag');

sub ROW_TAG_KEY {
    return 'MAIL_WANT_REPLY_TO';
}

sub get_default {
    return 1;
}

sub is_set_for_realm {
    return shift->row_tag_get(@_);
}

1;
