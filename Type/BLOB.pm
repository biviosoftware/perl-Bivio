# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::BLOB;
use strict;
use Bivio::Base 'Bivio.Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub from_literal {
    return defined($_[1]) ? \$_[1] : undef;
}

sub from_sql_column {
    return defined($_[1]) ? \$_[1] : undef;
}

sub to_literal {
    my(undef, $value) = @_;
    return ref($value) && defined($$value) ? $$value : '';
}

sub to_query {
    die("can't convert a blob to a query");
}

sub to_uri {
    die("can't convert a blob to a uri");
}

1;
