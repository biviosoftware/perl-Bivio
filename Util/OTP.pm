# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Util::OTP;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::OTP::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-otp [options] command [args...]
commands:
    to_six_word sequence_number seed [passphrase] -- generates a one time password
EOF
}

sub to_six_word {
    my($self, $count, $seed, $passphrase) = @_;
    $count = $self->convert_literal(OTPSequence => $count);
    $seed = $self->convert_literal(OTPSeed => $seed);
    $passphrase = $self->convert_literal(
	OTPPassphrase =>
	    $passphrase
	    || $self->use('Bivio::IO::TTY')->read_password('Passphrase: '));
    return Bivio::OTP::RFC2289->to_six_word_format(
        Bivio::OTP::RFC2289->compute($passphrase, $seed, $count)
    );
}

1;
