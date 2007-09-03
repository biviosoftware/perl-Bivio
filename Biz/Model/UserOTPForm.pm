# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::UserOTPForm;
use strict;
use Bivio::Base 'Model.UserPasswordForm';
use Bivio::Biz::RFC2289;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($user) = $self->get_request->get('auth_user');
    $self->new_other('OTP')->init_user($user, {
        otp_md5 => $self->get('OTP.otp_md5'),
        seed => $self->get('OTP.seed'),
    });
    $self->get_instance('UserLoginForm')->execute($self->get_request, {
	realm_owner => $user,
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
        map({{
	    name => $_,
	    type => 'Line',
	    constraint => 'NONE',
	}} qw(otp_challenge new_otp_challenge)),
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	'OTP.seed' => $self->get_field_type('OTP.seed')->generate
    )
	unless $self->get('OTP.seed');
    my($otp) = $self->new_other('OTP');
    $self->internal_put_field(new_otp_challenge =>
        $otp->get_challenge(undef, $self->get('OTP.seed')));
    $self->internal_put_field(otp_challenge => $otp->get_challenge())
	if $otp->unsafe_load();
    return;
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    my($otp) = Bivio::Biz::RFC2289
       ->from_six_word_format($self->get('new_password'));
    if ($otp) {
	$self->internal_put_field('OTP.otp_md5' => $otp);
    }
    else {
	$self->internal_put_field(new_password => undef);
	$self->internal_put_error(new_password => 'OTP_PASSWORD');
	$self->internal_put_field(confirm_new_password => undef);
    }
    if ($self->get_request->get('auth_user')->require_otp) {
	$self->internal_clear_error('old_password');
	$self->internal_put_error(old_password => 'OTP_PASSWORD_MISMATCH')
	    unless $self->new_other('OTP')->load()
		->verify($self->get('old_password'));
	$self->internal_put_error(qw(confirm_new_password CONFIRM_PASSWORD))
            unless $self->in_error
                || ($self->get('new_password')
		    eq $self->get('confirm_new_password'));
    }
    return;
}

1;
