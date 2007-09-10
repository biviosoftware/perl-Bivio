# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserOTPForm;
use strict;
use Bivio::Base 'Model.UserPasswordForm';
use Bivio::Biz::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    $self->new_other('OTP')->reset_auth_user(
	$self->get_model_properties('OTP'));
    $self->new_other('UserLoginForm')->process({
	realm_owner => $self->req('auth_user'),
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	hidden => [qw(
	    OTP.seed
	)],
	other => [
	    'OTP.otp_md5',
	    map(+{
		name => $_,
	        type => 'Line',
		constraint => 'NONE',
	    }, qw(otp_challenge new_otp_challenge)),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	'OTP.seed' => $self->get_field_type('OTP.seed')->generate
    ) unless $self->get('OTP.seed');
    my($otp) = $self->new_other('OTP');
    $self->internal_put_field(new_otp_challenge =>
        $otp->get_challenge(undef, $self->get('OTP.seed')));
    $self->internal_put_field(otp_challenge => $otp->get_challenge)
	if $otp->unsafe_load;
    return;
}

sub internal_validate_new {
    my($self) = @_;
    my($otp) = Bivio::Biz::RFC2289->canonical_hex($self->get('new_password'));
    unless ($otp) {
	$self->internal_put_field(new_password => undef);
	$self->internal_put_field(confirm_new_password => undef);
	return $self->internal_put_error(new_password => 'OTP_PASSWORD');
    }
    my($null) = Bivio::Biz::RFC2289->compute(
	$self->new_other('OTP')->get_field_type('sequence')->get_max,
	$self->get('OTP.seed'),
	'',
    );
    return $self->internal_put_error(new_password => 'NOT_ZERO')
	if $null eq $otp;
    $self->internal_put_field('OTP.otp_md5' => $otp);
    return;
}

sub internal_validate_old {
    my($self) = @_;
    return shift->SUPER::internal_validate_old(@_)
	unless $self->req('auth_user')->require_otp;
    return $self->internal_put_error(
	old_password => 'OTP_PASSWORD_MISMATCH'
    ) unless $self->new_other('OTP')->load
	->verify($self->get('old_password'));
    return 1;
}

1;
