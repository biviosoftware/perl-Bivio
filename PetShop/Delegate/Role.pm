# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Role;
use strict;
use Bivio::Base 'Bivio::Delegate::Role';

# C<Bivio::PetShop::Delegate::Role>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_delegate_info {
    # (self) : array_ref
    # Return test roles.
    return [
	@{shift->SUPER::get_delegate_info(@_)},
	TEST_ROLE1 => [21],
	TEST_ROLE2 => [22],
    ];
}

1;
