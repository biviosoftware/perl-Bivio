# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Gender;
use strict;
$Bivio::Type::Gender::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Gender - defines male, female, and unknown genders

=head1 SYNOPSIS

    use Bivio::Type::Gender;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Gender::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Gender> defines male, female, and unknown gender values.

=over 4

=item UNKNOWN

=item FEMALE

=item MALE

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    UNKNOWN => [0],
    FEMALE => [1],
    MALE => [2],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
