# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoCookie;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';


sub assert_is_ok {
    return 1;
}

sub header_out {
    return;
}

sub put_escaped {
    my($self) = @_;
    return shift->put(@_);
}

sub unsafe_get_escaped {
    my($self) = @_;
    return shift->unsafe_get(@_);
}

1;
