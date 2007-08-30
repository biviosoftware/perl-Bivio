# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Secret;
use strict;
use Bivio::Base 'Bivio::Type::String';
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::TTY;
use Bivio::IO::Trace;
use Bivio::MIME::Base64;
use Bivio::TypeError;
use Crypt::CBC;

# C<Bivio::Type::Secret> encrypts its values before storing in the DB.  The key
# is prompted if the configuration param I<prompt> is set to true.  Prompting at
# program startup if $ENV{MOD_PERL} is set or at first use if not.
#
# Database fields must be VARCHAR(4000) to allow for encryption expansion.
#
# Subclasses should define L<get_width|"get_width"> to be the value
# that the user enters.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_CFG);
my($_DEFAULT_VALUES) = {
    magic => 'X',
    algorithm => 'DES',
};
Bivio::IO::Config->register({
    prompt => 0,
    cipher => [],
});

sub decrypt_hex {
    my(undef, $encoded_hex) = @_;
    # Decrypts I<encoded_hex> and returns plain text.  If there is an
    # error decrypting, returns C<undef>.  If I<encoded_hex> is C<undef>,
    # returns C<undef>.
    return _decrypt($encoded_hex, 1);
}

sub decrypt_http_base64 {
    my($proto, $encoded_http_base64) = @_;
    # Same as L<decrypt_hex|"decrypt_hex"> but encodes with
    # L<Bivio::MIME::Base64|Bivio::MIME::Base64>.
    return _decrypt($encoded_http_base64, 0);
}

sub encrypt_hex {
    my($proto, $clear_text) = @_;
    # Encrypts I<clear_text> and returns encoded data in hex string.
    # If I<clear_text> is C<undef>, returns C<undef>.
    return _encrypt($clear_text, 1);
}

sub encrypt_http_base64 {
    my($proto, $clear_text) = @_;
    # Same as L<encrypt_hex|"encrypt_hex"> but encodes with
    # L<Bivio::MIME::Base64|Bivio::MIME::Base64>.
    return _encrypt($clear_text, 0);
}

sub from_sql_column {
    my($proto, $value) = @_;
    # Returns the string for this value.  Dies if there is an error parsing
    # the column from the database.
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

sub handle_config {
    my(undef, $cfg) = @_;
    # key : string (required)
    #
    # The way we encrypt the data.
    #
    # prompt : boolean [0]
    #
    # Do we need to prompt for a passphrase to decrypt I<key>?
    #
    # magic : string ['X']
    #
    # Should be short and non-numeric.  Placed on both ends of string
    # to "ensure" decryption worked.
    #
    # algorithm : string ['DES']
    #
    # Encryption algorithm.
    #
    # cipher : array_ref []
    #
    # A list of (key, magic, algorithm) keyed hashes. When decrypting,
    # the ciphers are applied in order until a match is found.
    # When encrypting the first value is used.
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

sub is_secure_data {
    # All secrets must be displayed/managed in a secure context.
    return 1;
}

sub to_sql_param {
    my($proto, $value) = @_;
    # Return the string of I<value>.
    return $proto->encrypt_hex($value);
}

sub _assert_cipher {
    # If cypher doesn't exist, blows up.
    return if ref(_default_cipher()->{key}) || _init_cipher();
    Bivio::Die->throw('CONFIG_ERROR', {
        entity => 'key',
        class => __PACKAGE__,
        message => 'no cipher configured',
    });
    # DOES NOT RETURN
}

sub _decrypt {
    my($encoded, $is_hex) = @_;
    # Decrypts $encoded based on $is_hex.
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

sub _decrypt_key {
    my($cipher, $phrase, $key_in) = @_;
    # Returns the key or undef.
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

sub _default_cipher {
    # Returns the default cipher.
    return $_CFG->{cipher}->[0];
}

sub _encrypt {
    my($clear_text, $is_hex) = @_;
    # Encrypts $clear_text based on $is_hex.
    return undef unless defined($clear_text);
    _assert_cipher();
    # Surround with magic and trailing time and encrypt
    my($cipher) = _default_cipher();
    my($v) = $cipher->{magic} . $clear_text . $cipher->{magic} . time;
    return $is_hex ? $cipher->{key}->encrypt_hex($v)
        : Bivio::MIME::Base64->http_encode($cipher->{key}->encrypt($v));
}

sub _init_cipher {
    # Initializes the cipher.
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

1;
