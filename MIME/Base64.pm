# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::MIME::Base64;
use strict;
$Bivio::MIME::Base64::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::MIME::Base64 - implements modified base64 operations

=head1 SYNOPSIS

    use Bivio::MIME::Base64;

=cut

use Bivio::UNIVERSAL;
@Bivio::MIME::Base64::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::MIME::Base64> implements a web-safe encoding of base64,
which we call http-base64.  The specials in Base64 are not
web friendly, so they are all replaced.

=cut

#=IMPORTS
use MIME::Base64 ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="http_decode"></a>

=head2 http_decode(string encoded) : string

Converts I<encoded> to an unencoded form using the rules for
http-base64 decoding.

=cut

sub http_decode {
    my(undef, $encoded) = @_;
    $encoded =~ tr/_*-/=+\//;
#TODO: Need to catch decode errors.  MIME::Base64 outputs warnings, but
#      silently succeeds.
    return MIME::Base64::decode($encoded);
}

=for html <a name="http_encode"></a>

=head2 http_encode(string decoded) : string

Converts I<decoded> to an encoded form using the rules for
http-base64 encoding.

=cut

sub http_encode {
    my(undef, $decoded) = @_;
    my($encoded) = MIME::Base64::encode($decoded, '');
    $encoded =~ tr/=+\//_*-/;
    return $encoded;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
