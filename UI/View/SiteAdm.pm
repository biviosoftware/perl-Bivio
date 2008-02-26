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
    return shift->internal_put_base_attr(
	tools => vs_alphabetical_chooser('AdmUserList'),
	body => vs_paged_list(AdmUserList => [
	    [display_name => {
		column_order_by => $_AUL->NAME_SORT_COLUMNS,
		want_sorting => 1,
                wf_list_link => {
                    query => 'THIS_DETAIL',
                    task => 'SITE_ADM_SUBSTITUTE_USER',
                },
	    }],
	    @{$extra_columns || []},
	]),
    );
}

1;
