# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECPointOfSale;
use strict;
$Bivio::Type::ECPointOfSale::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPointOfSale::VERSION;

=head1 NAME

Bivio::Type::ECPointOfSale - credit card point of sale

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECPointOfSale;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ECPointOfSale::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ECPointOfSale>

=over 4

=item UNKNOWN

=item PHONE

=item INTERNET

=item MAIL

=item IN_PERSON

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [0],
    PHONE => [1],
    INTERNET => [2],
    MAIL => [3],
    IN_PERSON => [4],
]);

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
