# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Secret;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_S) = __PACKAGE__->use('Type.Secret');
my($_R) = __PACKAGE__->use('Biz.Random');

sub USAGE {
    return <<'EOF';
usage: b-secret [options] command [args...]
commands:
    decrypt_hex value  -- decrypt hex string using current key
    encrypt_hex value  -- encrypt clear text using current key
    generate_bconf algorithm -- generate random bconf for algorithm
EOF
}

sub decrypt_hex {
    my(undef, $encoded_hex) = @_;
    return $_S->decrypt_hex($encoded_hex);
}

sub encrypt_hex {
    my(undef, $clear_text) = @_;
    return $_S->encrypt_hex($clear_text);
}

sub generate_bconf {
    my($self, $algorithm) = shift->name_args([
	['algorithm', 'PerlName'],
    ], \@_);
    my($keysize) = {
	Blowfish => 56,
	CAST5 => 16,
	DES => 16,
	DES_EDE3 => 24,
	IDEA => 16,
	Rijndael => 256,
    }->{$algorithm} || $self->usage_error($algorithm, ": unknown algorithm\n");
    my($key) = $_R->hex_digits($keysize * 2);
    my($magic) = $_R->string(3, [0-9, 'a' .. 'z', 'A' .. 'Z']);
    return <<"EOF";
use strict;
{
    'Bivio::Type::Secret' => {
        key => pack('H*', '$key'),
        magic => '$magic',
        algorithm => '$algorithm',
    },
};
EOF
}

1;
