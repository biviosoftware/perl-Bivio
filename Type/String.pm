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

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the value is invalid.

=cut

sub from_literal {
    shift;
#TODO: Better validation.
#TODO: NULL string handling.
    return shift;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
