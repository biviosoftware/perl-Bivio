# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Number;
use strict;
$Bivio::Type::Number::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Number - base class for all number types

=head1 SYNOPSIS

    use Bivio::Type::Number;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::Number::ISA = qw(Bivio::Type);

=head1 DESCRIPTION

C<Bivio::Type::Number> is the base class for all number types.
It is currently a placeholder.

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : string

Makes sure is a number.  Does not except scientific notation.

=cut

sub from_literal {
    my(undef, $value) = @_;
#TODO: Improve the checks here
    return $value =~ /^[-+]?\d+(?:\.\d+)?$/ ? $value : undef;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
