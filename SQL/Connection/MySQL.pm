# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::MySQL;
use strict;
use Bivio::Base 'Bivio::SQL::Connection';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_dbi_prefix {
    # Returns the PostgreSQL DBI connection prefix.
    return 'DBI:mysql:database=';
}

sub internal_get_retry_sleep {
    my($self, $error, $message) = @_;
    return 5 if $message =~ /MySQL server has gone away/;
    return undef;
}

1;
