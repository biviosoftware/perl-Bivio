# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::TOTPAlgorithm;
use strict;
use Bivio::Base 'Type.Enum';

my($_SECRET_BYTE_COUNT) = {
    SHA1 => 20,
    SHA256 => 32,
    SHA512 => 64,
};

__PACKAGE__->compile([
    UNKNOWN => 0,
    SHA1 => 1,
    SHA256 => 2,
    SHA512 => 3,
]);

sub get_secret_byte_count {
    my($self) = @_;
    return $_SECRET_BYTE_COUNT->{$self->get_name}
        || b_die('byte count not found');
}

1;
