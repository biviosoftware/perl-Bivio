# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Email;
use strict;
$Bivio::Type::Email::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Email - email address

=head1 SYNOPSIS

    use Bivio::Type::Email;

=cut

=head1 EXTENDS

L<Bivio::Type::Line>

=cut

use Bivio::Type::Line;
@Bivio::Type::Email::ISA = ('Bivio::Type::Line');

=head1 DESCRIPTION

C<Bivio::Type::Email> simple syntax checking on email addresses.

=cut


=head1 CONSTANTS

=cut

=for html <a name="IGNORE_PREFIX"></a>

=head2 IGNORE_PREFIX : string

Prefix we used to indicate ignored addresses.

=cut

sub IGNORE_PREFIX {
    return 'ignore-';
}

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES
# Borrowed from Bivio::Mail::Incoming.  Should really share code
my($_822_ATOM) = '[^][()<>@,;:\\\\". \\000-\\040\\177-\\377]+';
my($_822_DOTTED_ATOMS) = "$_822_ATOM(?:\\.$_822_ATOM)*";
my($_822_ATOM_ONLY_ADDR) = "$_822_DOTTED_ATOMS\@$_822_DOTTED_ATOMS";
my($_822_DOMAIN_LITERAL) = '\\[(?:(?:(?:\\\\{2})+|\\\\[^\\\\]|[^][\\\\])*)\\]';

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
    # We always force to lower case to ensure values get into the
    # database that can be searchable.
    $value = lc($value);
    # Must match a simple dotted atom address
#TODO: parse out address and try to do a DNS resolution?
#      I checked out Net::DNS, but it doesn't seem like it can
#      handle timeouts properly.  (No way to stop the query once
#      started(?)).  Anyway, we need a way to avoid entering bogus
#      addresses.  The best way would be to mail the user the password.
#      I don't know if we could sustain this in the beginning.
    return $value if $value =~ /^$_822_ATOM_ONLY_ADDR$/os;
#TODO: This is weak.  Either make good, or just use general message
#    # Give a reasonable error message
#    # We don't accept domain literal addresses?
#    return (undef, Bivio::TypeError::EMAIL_DOMAIN_LITERAL())
#	    if /$_822_DOMAIN_LITERAL/os;
#    # Must be qualified
#    return (undef, Bivio::TypeError::EMAIL_UNQUALIFIED())
#	    unless /\@/;
    # Some other error
    return (undef, Bivio::TypeError::EMAIL());
}

=for html <a name="is_valid"></a>

=head2 is_valid(string email) : boolean

Checks to see the email is a valid address.  Used to check
values stored in the database which may be invalidated by support.

=cut

sub is_valid {
    my($proto, $email) = @_;
    return defined($email) && $email =~ /^$_822_ATOM_ONLY_ADDR$/os
	    ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
