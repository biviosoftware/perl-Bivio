# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Type::CreditCardYear;
use strict;
$Bivio::PetShop::Type::CreditCardYear::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Type::CreditCardYear::VERSION;

=head1 NAME

Bivio::PetShop::Type::CreditCardYear - credit card year values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Type::CreditCardYear;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::PetShop::Type::CreditCardYear::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::PetShop::Type::CreditCardYear>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    Y2001 => [
        2001,
        '2001',
    ],
    Y2002 => [
        2002,
        '2002',
    ],
    Y2003 => [
        2003,
        '2003',
    ],
    Y2004 => [
        2004,
        '2004',
    ],
    Y2005 => [
        2005,
        '2005',
    ],
    Y2006 => [
        2006,
        '2006',
    ],
    Y2007 => [
        2007,
        '2007',
    ],
    Y2008 => [
        2008,
        '2008',
    ],
    Y2009 => [
        2009,
        '2009',
    ],
    Y2010 => [
        2010,
        '2010',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
