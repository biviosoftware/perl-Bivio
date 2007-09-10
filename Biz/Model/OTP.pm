# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::OTP;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::Biz::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    login_timeout_seconds => 3600,
    reinitialize_sequence => 10,
});

sub create {
    my($self, $values) = (shift, shift);
    return $self->SUPER::create(_values($self, $values), @_);
}

sub get_challenge {
    my($self, $sequence, $seed) = @_;
    if ($self->is_loaded) {
	$sequence ||= $self->get('sequence');
	$seed ||= $self->get('seed');
    }
    $sequence ||= $self->get_field_type('sequence')->get_max;
    return join(' ', 'otp_md5', $sequence, lc($seed));
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub should_reinit {
    return shift->get('sequence') <= $_CFG->{reinitialize_sequence}
	? 1 : 0;
}

sub validate_password {
    my($self, $passwd, $auth_user) = @_;
    $self->unauth_load_or_die({user_id => $auth_user->get('realm_id')});
    my($t) = $self->get_field_type('last_login');
    return $self->get('otp_md5') eq $passwd
	&& $t->diff_seconds($t->now, $self->get('last_login'))
	    <= $_CFG->{login_timeout_seconds}
	? 1 : 0;
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
            sequence => ['OTPSequence', 'NONE'],
	    last_login => ['DateTime', 'NOT_NULL'],
	},
	auth_id => 'user_id',
    });
}

sub reset_auth_user {
    my($self, $values) = @_;
    my($u) = $self->req('auth_user');
    $values->{user_id} = $u->get('realm_id');
    $u->update({password => $u->get_field_type('password')->OTP_VALUE});
    return $self->unauth_create_or_update($values);
}

sub update {
    my($self, $values) = (shift, shift);
    return $self->SUPER::update(_values($self, $values), @_);
}

sub verify {
    my($self, $input) = @_;
    my($otp_md5) = Bivio::Biz::RFC2289->canonical_hex($input);
    return 0
	unless $otp_md5;
    return 0
	unless Bivio::Biz::RFC2289->verify($otp_md5, $self->get('otp_md5'));
    $self->update({
        otp_md5 => $otp_md5,
        sequence => $self->get('sequence') - 1,
    });
    return 1;
}

sub _values {
    my($self, $values) = @_;
#TODO: Is this a good idea to hardcode here?  Shouldn't it be pulled from OTPForm? 
    $values->{sequence} = $self->get_field_type('sequence')->get_max - 1
	unless exists($values->{sequence});
    $values->{last_login} ||= $self->get_field_type('last_login')->now();
    return $values;
}

1;
