# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Secret;
use strict;
$Bivio::Type::Secret::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Secret::VERSION;

=head1 NAME

Bivio::Type::Secret - encrypted value in database, never displayed to user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Secret;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Secret::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::Secret> encrypts its values before storing in the DB.  The key
is prompted if the configuration param I<prompt> is set to true.  Prompting at
program startup if $ENV{MOD_PERL} is set or at first use if not.

Database fields must be VARCHAR(4000) to allow for encryption expansion.

Subclasses should define L<get_width|"get_width"> to be the value
that the user enters.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::TTY;
use Crypt::CBC;

#=VARIABLES
# Should be short and non-numeric.  Placed on both ends of string to "ensure"
# decryption worked.
my($_MAGIC) = 'X';
my($_ALGORITHM) = 'DES';
# Before initialization (_init_cipher()) is set to key
my($_CIPHER) = undef;
my($_PROMPT) = 0;
Bivio::IO::Config->register({
    key => Bivio::IO::Config->REQUIRED,
    prompt => $_PROMPT,
    magic => $_MAGIC,
    algorithm => $_ALGORITHM,
});

=head1 METHODS

=cut

=for html <a name="decrypt_hex"></a>

=head2 static decrypt_hex(string encoded_hex) : array

Decrypts I<encoded_hex> and returns plain text.  If there is an
error decrypting, returns C<undef>.  If I<encoded_hex> is C<undef>,
returns C<undef>.

=cut

sub decrypt_hex {
    my(undef, $encoded_hex) = @_;
    return undef unless $encoded_hex;
    _assert_cipher();

    # Decrypt and make sure surrounded by magic and a time not before now
    my($s) = $_CIPHER->decrypt_hex($encoded_hex);
    return undef unless
	    $s =~ s/^$_MAGIC//o && $s =~ s/$_MAGIC(\d+)$//o && time >= $1;
    return $s;
}

=for html <a name="encrypt_hex"></a>

=head2 static encrypt_hex(string clear_text) : string

Encrypts I<clear_text> and returns encoded data in hex string.
If I<clear_text> is C<undef>, returns C<undef>.

=cut

sub encrypt_hex {
    my($proto, $clear_text) = @_;
    return undef unless defined($clear_text);

    _assert_cipher();
    # Surround with magic and trailing time and encrypt
    return $_CIPHER->encrypt_hex($_MAGIC.$clear_text.$_MAGIC.time);
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string value) : string

Returns the string for this value.  Dies if there is an error parsing
the column from the database.

=cut

sub from_sql_column {
    my($proto, $value) = @_;
    return undef unless $value;

    my($s) = $proto->decrypt_hex($value);
    # There is a configuration error if we can't decrypt values from DB
    Bivio::Die->throw('CONFIG_ERROR',
	    {entity => 'key', class => __PACKAGE__,
	    message => 'unable to decrypt value'})
		unless defined($s);
    return $s;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item key : string (required)

The way we encrypt the data.

=item prompt : boolean [0]

Do we need to prompt for a passphrase to decrypt I<key>?

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CIPHER = $cfg->{key};
#TODO: Need a way to compute which programs need to decrypt the key.
    $_PROMPT = $cfg->{prompt};
    $_MAGIC = $cfg->{magic};
    $_ALGORITHM = $cfg->{algorithm};
    _init_cipher() if $ENV{MOD_PERL};
    return;
}

=for html <a name="is_secure_data"></a>

=head2 is_secure_data() : boolean

All secrets must be displayed/managed in a secure context.

=cut

sub is_secure_data {
    return 1;
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(string value) : string

Return the string of I<value>.

=cut

sub to_sql_param {
    my($proto, $value) = @_;
    return $proto->encrypt_hex($value);
}

#=PRIVATE METHODS

# _assert_cipher()
#
# If cypher doesn't exist, blows up.
#
sub _assert_cipher {
    return if ref($_CIPHER) || _init_cipher();
    Bivio::Die->throw('CONFIG_ERROR',
	    {entity => 'key', class => __PACKAGE__,
	    message => 'no cipher configured'});
    # DOES NOT RETURN
}

# _decrypt_key(string key_in) : string
#
# Returns the key or undef.
#
sub _decrypt_key {
    my($key_in) = @_;
    $_CIPHER = undef;

    my($p) = Bivio::IO::TTY->read_password(__PACKAGE__.' passphrase: ');
    unless (defined($p)) {
	Bivio::IO::Alert->warn('unable to open /dev/tty for key');
	return undef;
    }

    # Use this module to decrypt the key.  Protect against die, so
    # $_CIPHER can be reset.
    my($key_out) = Bivio::Die->eval(
	    sub {
		$_CIPHER = Crypt::CBC->new($p, $_ALGORITHM);
		return __PACKAGE__->from_sql_column($key_in);
	    });
    $_CIPHER = undef;
    Bivio::IO::Alert->warn('unable to decrypt key in config: ', $@)
		if $@;
    return $key_out;
}

# _init_cipher() : boolean
#
# Initializes the cipher.
#
sub _init_cipher {
    # If no key, then blow up.
    return 0 unless defined($_CIPHER);
    my($key) = $_CIPHER;
    $_CIPHER = undef;
    $key = _decrypt_key($key) if $_PROMPT;
    return 0 unless $key;
    $_CIPHER = Crypt::CBC->new($key, $_ALGORITHM);
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
