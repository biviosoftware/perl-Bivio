# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Amount;
use strict;
$Bivio::Type::Amount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Amount - describes the floating point type

=head1 SYNOPSIS

    use Bivio::Type::Amount;

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::Type::Amount::ISA = qw(Bivio::Type::Number);

=head1 DESCRIPTION

C<Bivio::Type::Amount> is a number used for all "floating point"
or "big integer"
computations, e.g. currencies, shares, and trading volume.
Computations with C<Bivio::Type::Amount> should be performed
with L<Math::BigFloat|Math::BigFloat>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CAN_BE_NEGATIVE"></a>

=head2 CAN_BE_NEGATIVE : boolean

Returns true.

=cut

sub CAN_BE_NEGATIVE {
    return 1;
}

=for html <a name="CAN_BE_POSITIVE"></a>

=head2 CAN_BE_POSITIVE : boolean

Returns true.

=cut

sub CAN_BE_POSITIVE {
    return 1;
}

=for html <a name="CAN_BE_ZERO"></a>

=head2 CAN_BE_ZERO : boolean

Returns true.

=cut

sub CAN_BE_ZERO {
    return 1;
}

=for html <a name="DECIMALS"></a>

=head2 DECIMALS : int

Returns 7.

=cut

sub DECIMALS {
    return 7;
}

=for html <a name="MAX"></a>

=head2 MAX : string

Returns '9999999999999.9999999'.

=cut

sub MAX {
    return '9999999999999.9999999';
}

=for html <a name="MIN"></a>

=head2 MIN : string

Returns '-9999999999999.9999999'.

=cut

sub MIN {
    return '-9999999999999.9999999';
}

=for html <a name="PRECISION"></a>

=head2 abstract PRECISION : int

Returns 20.

=cut

sub PRECISION {
    return 20;
}

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 22.

=cut

sub WIDTH {
    return 22;
}

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
