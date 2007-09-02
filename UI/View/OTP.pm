# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::OTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub form {
    return shift->internal_body(vs_simple_form(UserOTPForm => [qw(
	UserOTPForm.old_password
	'challenge
	UserOTPForm.new_password
	UserOTPForm.confirm_new_password
    )]));
}

1;
