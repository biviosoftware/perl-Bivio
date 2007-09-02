# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::OTP;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Biz::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-otp [options] command [args...]
commands:
    hex_key sequence_number seed [passphrase] -- returns one time password in hex
    six_word_key sequence_number seed [passphrase] -- returns in six word format
EOF
}

sub hex_key {
    my(undef, @args) = shift->arg_list(\@_, [
	'OTPSequence',
	'OTPSeed',
	[passphrase => OTPPassphrase => sub {
	     shift->use('Bivio::IO::TTY')->read_password('Passphrase: ');
	}],
    ]);
    return Bivio::Biz::RFC2289->compute(@args);
}

sub six_word_key {
    return Bivio::Biz::RFC2289->to_six_word_format(shift->hex_key(@_));
}

1;
