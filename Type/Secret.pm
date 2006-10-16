# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
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
use Bivio::IO::Trace;
use Bivio::TypeError;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::TTY;
use Bivio::MIME::Base64;
use Crypt::CBC;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_CFG);
my($_DEFAULT_VALUES) = {
    magic => 'X',
    algorithm => 'DES',
};
Bivio::IO::Config->register({
    prompt => 0,
    cipher => [],
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
    return _decrypt($encoded_hex, 1);
}


=for html <a name="encrypt_http_base64"></a>

=head2 static decrypt_http_base64(string encoded_http_base64) : string

Same as L<decrypt_hex|"decrypt_hex"> but encodes with
L<Bivio::MIME::Base64|Bivio::MIME::Base64>.

=cut

sub decrypt_http_base64 {
    my($proto, $encoded_http_base64) = @_;
    return _decrypt($encoded_http_base64, 0);
}

=for html <a name="encrypt_hex"></a>

=head2 static encrypt_hex(string clear_text) : string

Encrypts I<clear_text> and returns encoded data in hex string.
If I<clear_text> is C<undef>, returns C<undef>.

=cut

sub encrypt_hex {
    my($proto, $clear_text) = @_;
    return _encrypt($clear_text, 1);
}

=for html <a name="encrypt_http_base64"></a>

=head2 static encrypt_http_base64(string clear_text) : string

Same as L<encrypt_hex|"encrypt_hex"> but encodes with
L<Bivio::MIME::Base64|Bivio::MIME::Base64>.

=cut

sub encrypt_http_base64 {
    my($proto, $clear_text) = @_;
    return _encrypt($clear_text, 0);
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
    return $s if defined($s);
    # There is a configuration error if we can't decrypt values from DB
    Bivio::Die->throw('CONFIG_ERROR', {
        entity => 'key',
        class => __PACKAGE__,
        message => 'unable to decrypt value',
    });
    # DOES NOT RETURN
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item key : string (required)

The way we encrypt the data.

=item prompt : boolean [0]

Do we need to prompt for a passphrase to decrypt I<key>?

=item magic : string ['X']

Should be short and non-numeric.  Placed on both ends of string
to "ensure" decryption worked.

=item algorithm : string ['DES']

Encryption algorithm.

=item cipher : array_ref []

A list of (key, magic, algorithm) keyed hashes. When decrypting,
the ciphers are applied in order until a match is found.
When encrypting the first value is used.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;

    # if no ciphers defined, use the root config values
    if (defined($_CFG->{key}) && int(@{$_CFG->{cipher}}) == 0) {
        $_CFG->{cipher} = [{
            map({
                $_ => $_CFG->{$_},
            } (qw(key magic algorithm))),
        }];
    }

    foreach my $cipher (@{$_CFG->{cipher}}) {
        Bivio::Die->die('missing key, ', $cipher)
            unless defined($cipher->{key});

        foreach my $field (qw(magic algorithm)) {
            next if defined($cipher->{$field});
            $cipher->{$field} = $_DEFAULT_VALUES->{$field};
        }
    }
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
    return if ref(_default_cipher()->{key}) || _init_cipher();
    Bivio::Die->throw('CONFIG_ERROR', {
        entity => 'key',
        class => __PACKAGE__,
        message => 'no cipher configured',
    });
    # DOES NOT RETURN
}

# _decrypt(string encoded, boolean is_hex) : string
#
# Decrypts $encoded based on $is_hex.
#
sub _decrypt {
    my($encoded, $is_hex) = @_;
    return undef unless defined($encoded);
    _assert_cipher();

    # Decrypt and make sure surrounded by magic and a time not before now
    foreach my $cipher (@{$_CFG->{cipher}}) {
        next unless ref($cipher->{key});
        my($s) = $is_hex ? $cipher->{key}->decrypt_hex($encoded)
            : $cipher->{key}->decrypt(
                Bivio::MIME::Base64->http_decode($encoded) || '');
        my($magic) = $cipher->{magic};

        unless ($s =~ s/^\Q$magic\E//o && $s =~ s/\Q$magic\E(\d+)$//o
            && time >= $1) {
            _trace('cipher failed, trying next one') if $_TRACE;
            next;
        }
        _trace('cipher sucessful') if $_TRACE;
        return $s;
    }
    return undef;
}

# _decrypt_key(hash_ref cipher, string phrase, string key_in) : string
#
# Returns the key or undef.
#
sub _decrypt_key {
    my($cipher, $phrase, $key_in) = @_;
    $cipher->{key} = undef;

    # Use this module to decrypt the key.  Protect against die, so
    # cipher can be reset.
    my($key_out) = Bivio::Die->eval(
        sub {
            $cipher->{key} = Crypt::CBC->new($phrase, $cipher->{algorithm});
            return __PACKAGE__->from_sql_column($key_in);
        });
    $cipher->{key} = undef;
    Bivio::IO::Alert->warn('unable to decrypt key in config: ', $@)
        if $@;
    return $key_out;
}

# _default_cipher() : hash_ref
#
# Returns the default cipher.
#
sub _default_cipher {
    return $_CFG->{cipher}->[0];
}

# _encrypt(string clear_text, boolean is_hex) : string
#
# Encrypts $clear_text based on $is_hex.
#
sub _encrypt {
    my($clear_text, $is_hex) = @_;
    return undef unless defined($clear_text);
    _assert_cipher();
    # Surround with magic and trailing time and encrypt
    my($cipher) = _default_cipher();
    my($v) = $cipher->{magic} . $clear_text . $cipher->{magic} . time;
    return $is_hex ? $cipher->{key}->encrypt_hex($v)
        : Bivio::MIME::Base64->http_encode($cipher->{key}->encrypt($v));
}

# _init_cipher() : boolean
#
# Initializes the cipher.
#
sub _init_cipher {
    return 0 unless defined(_default_cipher()->{key});
    my($phrase);

    foreach my $cipher (@{$_CFG->{cipher}}) {
        my($key) = $cipher->{key};
        $cipher->{key} = undef;

        if ($_CFG->{prompt}) {
            $phrase ||= Bivio::IO::TTY->read_password(
                __PACKAGE__ . ' passphrase: ');

            unless (defined($phrase)) {
                Bivio::IO::Alert->warn('unable to open /dev/tty for key');
                return 0;
            }
            $key = _decrypt_key($cipher, $phrase, $key);
        }
        return 0 unless $key;
        $cipher->{key} = Crypt::CBC->new($key, $cipher->{algorithm});
    }
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
