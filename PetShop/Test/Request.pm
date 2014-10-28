# Copyright (c) 2003-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::Request;
use strict;
use Bivio::Base 'Bivio::Test::Request';


sub setup_facade {
    my($self) = shift->SUPER::setup_facade(@_);
    die('must be executed in PetShop environment')
	unless $self->get('UI.Facade')->simple_package_name eq 'PetShop';
    return $self;
}

1;
