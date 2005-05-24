# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# Enum property test
#
use strict;
use Bivio::Test;
use Bivio::PetShop::Model::Item;
use Bivio::Test::Request;
my($it);
Bivio::Test->unit([
    Bivio::PetShop::Model::Item->new(
	Bivio::Test::Request->get_instance) => [
            load => [
                [{item_id => 'EST-1'}] => undef,
            ],
            update => [
                [{status => Bivio::PetShop::Type::ItemStatus->DAMAGED}] =>
                    undef,
            ],
            get => [
                ['status'] => [Bivio::PetShop::Type::ItemStatus->DAMAGED],
            ],
        ],
]);
