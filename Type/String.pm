# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::String;
use strict;
$Bivio::Type::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::String - base class for all string types

=head1 SYNOPSIS

    use Bivio::Type::String;
    Bivio::Type::String->new();

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::String::ISA = qw(Bivio::Type);

=head1 DESCRIPTION

C<Bivio::Type::String> is the base class for all string types.
It is currently a placeholder.

=cut

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
