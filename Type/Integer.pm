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

Returns 0

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '999999999'.

=cut

sub get_max {
    return '999999999';
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '-999999999'.

=cut

sub get_min {
    return '-999999999';
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns 9.

=cut

sub get_precision {
    return 9;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 10.

=cut

sub get_width {
    return 10;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
