# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::UserAuth;
use strict;
use Bivio::Base 'View';
b_use('UI.ViewLanguageAUTOLOAD');


sub adm_substitute_user {
    return shift->internal_body(vs_simple_form(AdmSubstituteUserForm => [
	['AdmSubstituteUserForm.login' => {
	    wf_widget => ComboBox({
		field => 'login',
		list_class => 'AdmUserList',
		list_display_field => MailWidget_Mailbox()->new(
		    ['Email.email'],
		    ['RealmOwner.display_name'],
		),
		auto_submit => 1,
	    }),
	}],
    ]));
}

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
	'UserRegisterForm.Email.email',
	'UserRegisterForm.RealmOwner.display_name',
    ]));
}

1;
