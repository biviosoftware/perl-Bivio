# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::MIME::Base64;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use MIME::Base64 ();

# C<Bivio::MIME::Base64> implements a web-safe encoding of base64,
# which we call http-base64.  The specials in Base64 are not
# web friendly, so they are all replaced.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub http_decode {
    # (self, string) : string
    # Converts I<encoded> to an unencoded form using the rules for
    # http-base64 decoding.
    #
    # Returns C<undef> if the data couldn't be parsed.
    my(undef, $encoded) = @_;
    return undef unless $encoded && length($encoded) >= 4;
    $encoded =~ tr/_*-/=+\//;
    my($err) = 0;
    local($SIG{__WARN__}) = sub {
	$err++;
	Bivio::IO::Alert->warn(@_);
	return;
    };
    my($res) = MIME::Base64::decode($encoded);
    return $err ? undef : $res;
}

sub http_encode {
    # (self, string) : string
    # Converts I<decoded> to an encoded form using the rules for
    # http-base64 encoding.
    my(undef, $decoded) = @_;
    my($encoded) = MIME::Base64::encode($decoded, '');
    $encoded =~ tr/=+\//_*-/;
    return $encoded;
}

1;
