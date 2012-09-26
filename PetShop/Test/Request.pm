# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::Request;
use strict;
use Bivio::Base 'Bivio::Test::Request';

# C<Bivio::PetShop::Test::Request> will ensure the PetShop facade is
# setup.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub setup_facade {
    # (self) : self
    # Returns self but asserts facade is PetShop.
    my($self) = shift->SUPER::setup_facade(@_);
    die('must be executed in PetShop environment')
	unless $self->get('Bivio::UI::Facade')->simple_package_name
	    eq 'PetShop';
    return $self;
}

1;
