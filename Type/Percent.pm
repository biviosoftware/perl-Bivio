# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Percent;
use strict;
$Bivio::Type::Percent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Percent - a percentage type

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Percent;
    Bivio::Type::Percent->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Amount>

=cut

use Bivio::Type::Amount;
@Bivio::Type::Percent::ISA = ('Bivio::Type::Amount');

=head1 DESCRIPTION

C<Bivio::Type::Percent> a percentage type

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="calculate"></a>

=head2 static calculate(string amount, string total) : string

Returns 100 * amount / total.
Returns 0 if total is 0.

=cut

sub calculate {
    my($proto, $amount, $total) = @_;

    return $total == 0
	    ? 0
	    : $proto->div($proto->mul($amount, 100), $total);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
