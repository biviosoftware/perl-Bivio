# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Language::Scraper;
use strict;
use Bivio::Base 'Bivio::Test::Language::HTTP';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_setup {
    # Don't call SUPER, because we don't want to time out a server
    return;
}

sub user_agent {
    return 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)';
}

1;
