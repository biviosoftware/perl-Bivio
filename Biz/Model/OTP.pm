# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Model::OTP;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base 'Bivio::Biz::PropertyModel';

use Bivio::OTP::RFC2289;
use Bivio::Type::DateTime;

#=VARIABLES
my($_DT) = 'Bivio::Type::DateTime';

=head1 METHODS

=cut

sub create {
    my($self, $values) = @_;
    $values->{last_login} = Bivio::Type::DateTime->now()
	unless exists($values->{last_login});
    return shift->SUPER::create(@_);
}

sub get_challenge {
    my($self) = @_;
    return join(' ', 'otp-md5', $self->get('count'), $self->get('seed'));
}

sub has_timed_out {
    my($self) = @_;
    return $_DT->diff_seconds($_DT->now, $self->get('last_login'))
	> 60*60;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'otp_t',
	columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            otp_md5 => ['OTPMD5', 'NONE'],
            seed => ['OTPSeed', 'NONE'],
            count => ['OTPSequence', 'NONE'],
	    last_login => ['DateTime', 'NOT_NULL'],
	},
	auth_id => 'user_id',
    });
}

sub verify {
    my($self, $input) = @_;
    my($otp_md5) = Bivio::OTP::RFC2289->canonical_hex($input);
    return 0
	unless $otp_md5;
    return 0
	unless Bivio::OTP::RFC2289->verify($otp_md5, $self->get('otp_md5'));
    $self->update({
        otp_md5 => $otp_md5,
        count => $self->get('count') - 1,
        last_login => Bivio::Type::DateTime->now(),
    });
    return 1;
}

1;
