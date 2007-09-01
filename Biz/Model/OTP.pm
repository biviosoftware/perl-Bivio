# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::Model::OTP;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base 'Bivio::Biz::PropertyModel';

use Bivio::OTP::RFC2289;

sub get_challenge {
    my($self) = @_;
    return join(' ', 'otp-md5', $self->get('count'), $self->get('seed'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'otp_t',
	columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            otp_md5 => ['Line', 'NONE'],
            seed => ['Line', 'NONE'],
            count => ['Number', 'NONE'],
	},
	auth_id => 'realm_id',
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
    });
    return 1;
}

1;
