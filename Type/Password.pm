# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Password;
use strict;
use Bivio::Base 'Type.Name';
use Bivio::TypeError;

# C<Bivio::Type::Password> indicates the input is a password entry.
# It should be handled with care, e.g. never displayed to user.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my(@_SALT_CHARS) = (
    'a'..'z',
    'A'..'Z',
    '0'..'9',
);
my($_SALT_INDEX_MAX) = int(@_SALT_CHARS) - 1;
# All passwords are exactly the same length
my($_VALID_LENGTH) = length(__PACKAGE__->encrypt('anything'));

sub INVALID {
    # Returns invalid password (save literally!).
    return 'xx';
}

sub compare {
    my(undef, $encrypted, $incoming) = @_;
    # Encrypts I<incoming> using I<salt> from I<encrypted>.
    # Returns true if encrypted versions match.
    #
    # C<undef> values are never equal.  This avoids security problems.
    # Only equal if both values are defined
    return -1
	unless defined($encrypted);
    return 1
	unless defined($incoming);
    return crypt($incoming, substr($encrypted, 0, 2)) cmp $encrypted;
}

sub encrypt {
    my(undef, $password) = @_;
    # Encrypts the password with a random I<salt> string.
    my($salt) = '';
    for (my($i) = 0; $i < 2; $i++) {
	$salt .= $_SALT_CHARS[int(rand($_SALT_INDEX_MAX) + 0.5)];
    };
    return crypt($password, $salt);
}

sub from_literal {
    my($proto, $value) = @_;
    # Returns C<undef> if the name is empty.  All characters are allowed.
    $proto->internal_from_literal_warning
        unless wantarray;
    return undef unless defined($value) && length($value);
    return (undef, Bivio::TypeError::PASSWORD()) if length($value) < 6;
#TODO: What type of checks should be here?
#TODO: Should we limit length to say 16 chars?
#TODO: Should length check be here? (Someone hacked form, but who cares?)
    return $value;
}

sub is_password {
    # Returns true.
    return 1;
}

sub is_secure_data {
    # Don't render in logs.
    return 1;
}

sub is_valid {
    my(undef, $value) = @_;
    # Returns true if I<value> is valid.
    return $value && length($value) == $_VALID_LENGTH ? 1 : 0;
}

1;
