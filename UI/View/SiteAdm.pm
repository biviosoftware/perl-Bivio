# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::SiteAdm;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_AUL) = __PACKAGE__->use('Model.AdmUserList');

sub substitute_user_form {
    return shift->internal_body(vs_simple_form(SiteAdmSubstituteUserForm => [qw{
	SiteAdmSubstituteUserForm.login
    }]));
}

sub user_list {
    my($self, $extra_columns) = @_;
    vs_user_email_list('AdmUserList', $extra_columns);
    return;
}

1;
