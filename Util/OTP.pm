# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::OTP;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Biz::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NULL_PASSPHRASE {
    return 'NULL_PASSPHRASE';
}

sub USAGE {
    return <<'EOF';
usage: b-otp [options] command [args...]
commands:
    hex_key [sequence_number seed [passphrase]] -- returns one time password in hex
    reset_user [sequence_number seed [passphrase]] -- reset auth_user's OTP record
    six_word_key [sequence_number seed [passphrase]] -- returns in six word format
EOF
}

sub hex_key {
    my($self, @args) = _args(@_);
    $args[2] = ''
        if $args[2] eq $self->NULL_PASSPHRASE;
    return Bivio::Biz::RFC2289->compute(@args);
}

sub reset_user {
    my($self, $seq, $seed, $pass) = _args(@_);
    my($res) = Bivio::Biz::RFC2289->compute($seq + 1, $seed, $pass);
    $self->model('OTP')->reset_auth_user({
	otp_md5 => $res,
	sequence => $seq,
	seed => $seed,
    });
    return $res;
}

sub six_word_key {
    return Bivio::Biz::RFC2289->to_six_word_format(shift->hex_key(@_));
}

sub _args {
    my($self) = shift;
    my($seq) = 1;
    return $self->name_args([
	[sequence => OTPSequence => sub {
	     $seq = 0;
	     return $self->model('OTP')->get_field_type('sequence')->get_max;
	}],
	[qw(seed OTPSeed yourseed)],
	[passphrase => OTPPassphrase => sub {
	     return $seq
		 ? shift->use('Bivio::IO::TTY')->read_password('Passphrase: ')
		 : shift->use('ShellUtil.SQL')->TEST_PASSWORD;
	}],
    ], \@_);
}

1;
