# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::ClubUserTitle;
use strict;
$Bivio::Type::ClubUserTitle::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::ClubUserTitle - titles of club users

=head1 SYNOPSIS

    use Bivio::Type::ClubUserTitle;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ClubUserTitle::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ClubUserTitle> defines a list of club user titles.
These titles are not stored as an enum in the database.

=over 4

=item UNKNOWN

=item FEMALE

=item MALE

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    UNKNOWN => [
	0,
	'Unspecified',
    ],
    PARTNER => [
	1,
    ],
    TREASURER => [
	2,
    ],
    PRESIDENT => [
	3,
    ],
    VICE_PRESIDENT => [
	4,
    ],
    SECRETARY => [
	5,
    ],
    ADMINISTRATOR => [
	6,
    ],
    MEMBER => [
	7,
    ],
    GUEST => [
	8,
    ],
);

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
