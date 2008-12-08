# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RoleSelectList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');
my($_T) = b_use('FacadeComponent.Text');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmUser.role'],
	other => [
	    $self->field_decl(['display'], 'Line'),
	],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    return [map(
	+{
	    'RealmUser.role' => $_,
	    display => $_T->get_value_for_auth_realm(
		'RoleSelectList.display_name.' . $_->get_name,
		$self->req,
	    ),
	},
	@{$query->get('values_array')},
    )];
}

sub load_from_array {
    my($self, $values) = @_;
    return shift->load_all({
	values_array => [map($_R->from_any($_), @$values)],
    });
}

1;
