# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Phone;
use strict;
$Bivio::Type::Phone::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Phone - phone number

=head1 SYNOPSIS

    use Bivio::Type::Phone;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::Phone::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::Phone> simple syntax checking on phone numbers.

=cut

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns C<undef> if the name is empty or zero length.
Checks syntax and returns L<Bivio::TypeError|Bivio::TypeError>.

=cut

sub from_literal {
    my($proto, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces, because user can't have them
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    return (undef, Bivio::TypeError::TOO_LONG())
	    if length($value) > $proto->get_width;
#TODO: Do we need to parse better?
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
