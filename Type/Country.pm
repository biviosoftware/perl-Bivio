# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Country;
use strict;
$Bivio::Type::Country::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Country - country code

=head1 SYNOPSIS

    use Bivio::Type::Country;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Country::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::Country> represents the country in the database.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if empty.
Leading and trailing blanks are trimmed.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Leave middle spaces in case a "display" name.
    $value =~ s/^\s+|\s+$//g;
    return undef unless length($value);
    return (undef, Bivio::TypeError::COUNTRY())
	    unless $value =~ /^[a-z]{2}$/i;
    return uc($value);
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 2.

=cut

sub get_width {
    return 2;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
