# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::GroupAdmin;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub substitute_user_form {
    return shift->internal_body(vs_simple_form(SiteAdmSubstituteUserForm => [qw{
	SiteAdmSubstituteUserForm.login
    }]));
}

sub user_list {
    my($self, $extra_columns) = @_;
    vs_user_email_list(
	'GroupUserList',
	[
	    'privileges',
	    @{$extra_columns || []},
	],
    );
    return;
}

1;
