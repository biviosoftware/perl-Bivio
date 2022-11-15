# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::OTP;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub form {
    return shift->internal_body(vs_simple_form(UserOTPForm => [qw(
        'challenge
        UserOTPForm.old_password
        'new_challenge
        UserOTPForm.new_password
        UserOTPForm.confirm_new_password
    )]));
}

1;
