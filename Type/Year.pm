# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Year;
use strict;
$Bivio::Type::Year::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Year::VERSION;

=head1 NAME

Bivio::Type::Year - date year field type

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Year;
    Bivio::Type::Year->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Integer>

=cut

use Bivio::Type::Integer;
@Bivio::Type::Year::ISA = ('Bivio::Type::Integer');

=head1 DESCRIPTION

C<Bivio::Type::Year> date year field type

=cut

=head1 CONSTANTS

=cut

=for html <a name="WINDOW_SIZE"></a>

=head2 WINDOW_SIZE : int

Number of years in the future that counts in this century, unless it crosses
year boundaries.

=cut

sub WINDOW_SIZE {
    return 20;
}

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Converts value.  Handles date windowing (+20 years).

=cut

sub from_literal {
    my($proto) = shift;
    my($res, $err) = $proto->SUPER::from_literal(@_);
    return ($res, $err)
        unless $err && $err == Bivio::TypeError->NUMBER_RANGE;
    ($res, $err) = Bivio::Type::Integer->from_literal(@_);
    return ($res, $err)
	if $err;
    return (undef, Bivio::TypeError->NUMBER_RANGE)
	unless $res >= 0 && $res < 100;
    my($century) = int(Bivio::Type::DateTime->now_as_year / 100) * 100;
    return ($res + $century -
		($res <= Bivio::Type::DateTime->now_as_year % 100
		     + $proto->WINDOW_SIZE
		? 0 : 100),
	    undef);
}

=for html <a name="get_max"></a>

=head2 static get_max : int

Returns 9999.

=cut

sub get_max {
    return '9999';
}

=for html <a name="get_min"></a>

=head2 static get_min : int

Returns 100.

=cut

sub get_min {
    return 100;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 4.

=cut

sub get_width {
    return 4;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
