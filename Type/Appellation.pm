# Copyright (c) 2005 bivio Software, Inc..  All Rights Reserved.
# $Id$
package Bivio::Type::Appellation;
use strict;
$Bivio::Type::Appellation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Appellation::VERSION;

=head1 NAME

Bivio::Type::Appellation - titles

=head1 RELEASE SCOPE

Bivio

=head1 SYNOPSIS

    use Bivio::Type::Appellation;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Appellation::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Appellation>

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
