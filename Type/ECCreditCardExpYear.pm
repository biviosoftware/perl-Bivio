# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::ECCreditCardExpYear;
use strict;
$Bivio::Type::ECCreditCardExpYear::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECCreditCardExpYear::VERSION;

=head1 NAME

Bivio::Type::ECCreditCardExpYear - list of possible credit card expiration years

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECCreditCardExpYear;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECCreditCardExpYear::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECCreditCardExpYear>

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile([
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
    Y2011 => [
        2011,
        '2011',
    ],
    Y2012 => [
        2012,
        '2012',
    ],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
