# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::GroupUserQueryForm;
use strict;
use Bivio::Base 'Model.FilterQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = b_use('FacadeComponent.Text');

sub get_privilege_role {
    my($self) = @_;
    return _role_map($self)->{$self->get('b_privilege') || ''};
}

sub internal_query_fields {
    return [
	@{shift->SUPER::internal_query_fields(@_)},
	[qw(b_privilege Text)],
    ];
}

sub provide_select_choices {
    my($self) = @_;
    return [sort(keys(%{_role_map($self)}))];
}

sub to_html {
    my($self, $v) = @_;
    return b_use('Bivio::HTML')->escape($v);
}

sub _role_map {
    my($self) = @_;
    return {map({
	my($v) = $_T->get_from_source($self->req)
	    ->unsafe_get_value('GroupUserList.privileges_name',	$_->get_name);
	$v ? ($v => $_) : ();
    } @{b_use('Model.RoleBaseList')->ROLES_ORDER})};
}

1;
