# Copyright (c) 2026 bivio Software, Inc.  All rights reserved.
package Bivio::Type::PasswordHashArgon2ID;
use strict;
use Bivio::Base 'Type.PasswordHashBase';
use Crypt::Argon2 ();

# OWASP recommendation for argon2id params
my($_MEMORY_COST) = '19456k';
my($_TIME_COST) = 2;
my($_PARALLELISM) = 1;

my($_TAG_SIZE) = 32;
my($_SALT_BYTES) = 16;
my($_R) = b_use('Biz.Random');
my($_D) = b_use('Bivio.Die');

sub ID {
    return 'argon2id';
}

sub REGEX {
    return qr{^\$argon2id\$v=\d+\$m=\d+,t=\d+,p=\d+\$[A-Za-z0-9+/]+\$[A-Za-z0-9+/]+$};
}

sub SALT_LENGTH {
    return $_SALT_BYTES;
}

sub as_literal {
    # argon2 PHC format is self-contained (algorithm, version, params, salt,
    # tag) so we store and return it verbatim rather than re-wrapping in the
    # base class's $id$salt$hash format.
    return shift->get_hash;
}

sub compare {
    my($self, $clear_text) = @_;
    # argon2_verify does constant-time tag comparison internally, so Biz.SecureCompare is not
    # needed. Catch errors so a malformed stored hash falls through as not matching rather than
    # crashing.
    my($ok);
    $_D->catch_quietly(sub {
        $ok = Crypt::Argon2::argon2_verify(
            $self->get_hash, defined($clear_text) ? $clear_text : '');
    });
    return $ok ? 0 : 1;
}

sub internal_format_literal {
    b_die('unused method');
}

sub internal_random_salt {
    return $_R->bytes($_SALT_BYTES);
}

sub internal_to_literal {
    my($proto, $clear_text, $salt) = @_;
    return Crypt::Argon2::argon2id_pass(
        defined($clear_text) ? $clear_text : '',
        $salt,
        $_TIME_COST,
        $_MEMORY_COST,
        $_PARALLELISM,
        $_TAG_SIZE,
    );
}

sub internal_to_parts {
    my($proto, $value) = @_;
    # Full PHC string lives in `hash`; `salt` exposes the base64 salt field
    # for inspection only (compare() uses the full string via argon2_verify).
    return {
        id => $proto->ID,
        salt => (split(/\$/, $value))[4],
        hash => $value,
    };
}

1;
