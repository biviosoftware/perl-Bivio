# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Boolean;
use strict;
$Bivio::Type::Boolean::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Boolean - formal numeric specification of the boolean type

=head1 SYNOPSIS

    use Bivio::Type::Boolean;

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::Type::Boolean::ISA = qw(Bivio::Type::Number);

=head1 DESCRIPTION

C<Bivio::Type::Boolean> describes the boolean type.  It is not a wrapper, just
something to convert.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CAN_BE_NEGATIVE"></a>

=head2 CAN_BE_NEGATIVE : boolean

Returns false.

=cut

sub CAN_BE_NEGATIVE {
    return 0;
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

Returns 0.

=cut

sub DECIMALS {
    return 0;
}

=for html <a name="MAX"></a>

=head2 MAX : int

Returns 1.

=cut

sub MAX {
    return 1;
}

=for html <a name="MIN"></a>

=head2 MIN : int

Returns 0.

=cut

sub MIN {
    return 0;
}

=for html <a name="PRECISION"></a>

=head2 PRECISION : int

Returns 1.

=cut

sub PRECISION {
    return 1;
}

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 1.

=cut

sub WIDTH {
    return 1;
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param) : string

Returns '0' or '1' for false (or undef) and true.

=cut

sub to_sql_param {
    shift;
    return shift(@_) ? '1' : '0';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
