# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Secret;
use strict;
$Bivio::Util::Secret::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::Secret::VERSION;

=head1 NAME

Bivio::Util::Secret - manipulate secrets

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::Secret;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::Secret::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::Secret> manipulate L<Bivio::Type::Secret|Bivio::Type::Secret>.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

 usage: b-secret [options] command [args...]
 commands:
    decrypt_hex value  -- decrypt hex string using current key
    encrypt_hex value  -- encrypt clear text using current key

=cut

sub USAGE {
    return <<'EOF';
usage: b-secret [options] command [args...]
commands:
    decrypt_hex value  -- decrypt hex string using current key
    encrypt_hex value  -- encrypt clear text using current key
EOF
}

#=IMPORTS
use Bivio::Type::Secret;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="decrypt_hex"></a>

=head2 decrypt_hex(string encoded_hex) : string

Returns clear text.  See
L<Bivio::Type::Secret::decrypt_hex|Bivio::Type::Secret/"decrypt_hex">.

Does not return a trailing newline.

=cut

sub decrypt_hex {
    my(undef, $encoded_hex) = @_;
    return Bivio::Type::Secret->decrypt_hex($encoded_hex);
}

=for html <a name="encrypt_hex"></a>

=head2 encrypt_hex(string clear_text) : string

Returns encoded text as hex.  See
L<Bivio::Type::Secret::encrypt_hex|Bivio::Type::Secret/"encrypt_hex">.

Does not return a trailing newline.

=cut

sub encrypt_hex {
    my(undef, $clear_text) = @_;
    return Bivio::Type::Secret->encrypt_hex($clear_text);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
