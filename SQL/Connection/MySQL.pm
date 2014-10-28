# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::MySQL;
use strict;
use Bivio::Base 'Bivio::SQL::Connection';


sub get_dbi_prefix {
    # Returns the PostgreSQL DBI connection prefix.
    return 'DBI:mysql:database=';
}

sub internal_get_retry_sleep {
    my($self, $error, $message) = @_;
    return 15 if $message =~ /MySQL server through socket/;
    return 5 if $message =~ /MySQL server has gone away/;
    return undef;
}

1;
