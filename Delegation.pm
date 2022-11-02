# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegation;
use strict;
use Bivio::Base 'Collection.Attributes';


sub internal_as_string {
    my($self) = @_;
    return $self->unsafe_get(qw(calling_package method delegator));
}

sub new {
    my($proto, $delegate, $delegator) = @_;
    return $proto->SUPER::new({
        calling_package => (caller(1))[0],
        method => $proto->my_caller(1),
        delegate => $delegate,
        delegator => $delegator,
    });
}

1;
