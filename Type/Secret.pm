# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Secret;
use strict;
$Bivio::Type::Secret::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Secret - encrypted data

=head1 SYNOPSIS

    use Bivio::Type::Secret;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::Secret::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::Secret> to encrypt a string.  It uses IDEA encryption.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Crypt::CBC;


#=VARIABLES
# Should be short and non-numeric.  Placed on both ends of string to "ensure"
# decryption worked.
my($_MAGIC) = 'BWN';
my($_CIPHER) = undef;
Bivio::IO::Config->register({
    key => Bivio::IO::Config->REQUIRED,
});

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns the unecrypted I<value>.

=cut

sub from_literal {
    my(undef, $value) = @_;

    return undef unless $value;

    # Decrypt and make sure surrounded by magic and a time not before now
    my($s) = $_CIPHER->decrypt_hex($value);
    return (undef, Bivio::TypeError::SECRET()) unless
	    $s =~ s/^$_MAGIC//o && $s =~ s/$_MAGIC(\d+)$//o && time >= $1;
    return ($s);
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string value) : string

Returns the string for this value.  Dies if there is an error parsing
the column from the database.

=cut

sub from_sql_column {
    my($value, $error) = shift->from_literal(@_);
    Bivio::Die->die($error, {entity => $_[0]}) if $error;
    return $value;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item key : string (required)

The way we encrypt the data.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Carp::croak("$cfg->{domain}: domain must have two dots in it")
		unless !$cfg->{domain} || $cfg->{domain} =~ /\..*\./;
    $_CIPHER = Crypt::CBC->new($cfg->{key}, 'IDEA');
    return;
}

=for html <a name="to_literal"></a>

=head2 static to_literal(string value) : string

Returns I<value> encrypted.

=cut

sub to_literal {
    my(undef, $value) = @_;
    return undef unless defined($value);
    # Surround with magic and trailing time and encrypt
    return $_CIPHER->encrypt_hex($_MAGIC.$value.$_MAGIC.time);
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(string value) : string

Return the string of I<value>.

=cut

sub to_sql_param {
    shift->to_literal(@_);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
