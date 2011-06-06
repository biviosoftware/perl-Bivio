# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECPaymentMethod;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    CREDIT_CARD => [1],
    BANK_CHECK => [2, 'Check'],
    NO_PAYMENT => [3],
]);

1;
