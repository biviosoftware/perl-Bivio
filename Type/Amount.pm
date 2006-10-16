# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Amount;
use strict;
$Bivio::Type::Amount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Amount::VERSION;

=head1 NAME

Bivio::Type::Amount - describes the floating point type

=head1 RELEASE SCOPE

bOP

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

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Returns true.

=cut

sub can_be_negative {
    return 1;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Returns true.

=cut

sub can_be_positive {
    return 1;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns true.

=cut

sub can_be_zero {
    return 1;
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 6.

=cut

sub get_decimals {
    return 6;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '9999999999999.9999999'.

=cut

sub get_max {
    return '9999999999999.999999';
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '-9999999999999.9999999'.

=cut

sub get_min {
    return '-9999999999999.999999';
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns 20.

=cut

sub get_precision {
    return 20;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 22 (includes decimal and sign).

=cut

sub get_width {
    return 22;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
