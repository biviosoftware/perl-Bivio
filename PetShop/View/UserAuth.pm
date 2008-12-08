# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::UserAuth;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
	'UserRegisterForm.Email.email',
	'UserRegisterForm.RealmOwner.display_name',
    ]));
}

1;
