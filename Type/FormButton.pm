# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::FormButton;
use strict;
$Bivio::Type::FormButton::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::FormButton - field to prompt instrument lookup

=head1 SYNOPSIS

    use Bivio::Type::FormButton;
    Bivio::Type::FormButton->new();

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::FormButton::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::FormButton> a form button type

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
