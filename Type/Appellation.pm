# Copyright (c) 2005 bivio Software, Inc..  All Rights Reserved.
# $Id$
package OxAlumNY::Type::Appellation;
use strict;
$OxAlumNY::Type::Appellation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $OxAlumNY::Type::Appellation::VERSION;

=head1 NAME

OxAlumNY::Type::Appellation - titles

=head1 RELEASE SCOPE

OxAlumNY

=head1 SYNOPSIS

    use OxAlumNY::Type::Appellation;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@OxAlumNY::Type::Appellation::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<OxAlumNY::Type::Appellation>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [0, 'None'],
    DR => [1, 'Dr.'],
    MR => [2, 'Mr.'],
    MRS => [3, 'Mrs.'],
    MS => [4, 'Ms.'],
]);

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc..  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
