# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Password;
use strict;
$Bivio::Type::Password::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Password::VERSION;

=head1 NAME

Bivio::Type::Password - a password value checker and utilities

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Password;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::Password::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::Password> indicates the input is a password entry.
It should be handled with care, e.g. never displayed to user.

=cut


=head1 CONSTANTS

=cut

=for html <a name="INVALID"></a>

=head2 INVALID : string

Returns invalid password (save literally!).

=cut

sub INVALID {
    return 'xx';
}

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(@_SALT_CHARS) = (
    'a'..'z',
    'A'..'Z',
    '0'..'9',
);
my($_SALT_INDEX_MAX) = int(@_SALT_CHARS) - 1;
# All passwords are exactly the same length
my($_VALID_LENGTH) = length(__PACKAGE__->encrypt('anything'));

=head1 METHODS

=cut

=for html <a name="is_equal"></a>

=head2 static is_equal(string encrypted, string incoming) : boolean

Encrypts I<incoming> using I<salt> from I<encrypted>. Throws
Returns true if encrypted versions match.

=cut

sub is_equal {
    my($undef, $encrypted, $incoming) = @_;
    return crypt($incoming, substr($encrypted, 0, 2)) eq $encrypted;
}

=for html <a name="encrypt"></a>

=head2 static encrypt(string password) : string

Encrypts the password with a random I<salt> string.

=cut

sub encrypt {
    my(undef, $password) = @_;
    my($salt) = '';
    for (my($i) = 0; $i < 2; $i++) {
	$salt .= $_SALT_CHARS[int(rand($_SALT_INDEX_MAX) + 0.5)];
    };
    return crypt($password, $salt);
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : any

Returns C<undef> if the name is empty.  All characters are allowed.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value) && length($value);
    return (undef, Bivio::TypeError::PASSWORD()) if length($value) < 6;
#TODO: What type of checks should be here?
#TODO: Should we limit length to say 16 chars?
#TODO: Should length check be here? (Someone hacked form, but who cares?)
    return $value;
}

=for html <a name="is_password"></a>

=head2 static is_password() : boolean

Returns true.

=cut

sub is_password {
    return 1;
}

=for html <a name="is_valid"></a>

=head2 static is_valid(string value) : boolean

Returns true if I<value> is valid.

=cut

sub is_valid {
    my(undef, $value) = @_;
    return $value && length($value) == $_VALID_LENGTH ? 1 : 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
