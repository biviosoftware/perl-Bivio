# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Integer;
use strict;
$Bivio::Type::Integer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Integer - describes the numeric primary (object) id

=head1 SYNOPSIS

    use Bivio::Type::Integer;

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::Type::Integer::ISA = qw(Bivio::Type::Number);

=head1 DESCRIPTION

C<Bivio::Type::Integer> is a number used for "small integer"
computations, e.g. byte counts and list_display_size.
An <Bivio::Type::Integer> always fits into a perl int.

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

Returns 0

=cut

sub DECIMALS {
    return 0;
}

=for html <a name="MAX"></a>

=head2 MAX : string

Returns '999999999'.

=cut

sub MAX {
    return '999999999';
}

=for html <a name="MIN"></a>

=head2 MIN : string

Returns '-999999999'.

=cut

sub MIN {
    return '-999999999';
}

=for html <a name="PRECISION"></a>

=head2 PRECISION : int

Returns 9.

=cut

sub PRECISION {
    return 9;
}

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 10.

=cut

sub WIDTH {
    return 10;
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
