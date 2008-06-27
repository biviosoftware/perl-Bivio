# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::SQL::t::Statement::T1List;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => ['RealmFile.realm_id'],
	order_by => [
	    'RealmOwner.name',
#TODO: Get to work with LEFT_JOIN
#	    'guest.RealmOwner.name',
	    ['RealmFile.path', ['/']],
	    ['RealmOwner.realm_type', ['USER']],
	    ['RealmUser.role', ['ADMINISTRATOR']],
	    {
		name => 'guest_name',
		type => 'RealmName',
		constraint => 'NONE',
		select_value => "(SELECT guest_ro.name
                    FROM realm_user_t guest_ru, realm_owner_t guest_ro
                    WHERE guest_ru.role = @{[b_use('Auth.Role')->GUEST->as_sql_param]}
                    AND guest_ru.realm_id = realm_user_t.user_id
                    AND guest_ru.user_id = guest_ro.realm_id
                ) as guest_name",
	    },
	],
	other => [
	    ['RealmFile.realm_id', 'RealmOwner.realm_id', 'RealmUser.realm_id'],
	],
    });
}

# sub internal_prepare_statement {
#     my($self, $stmt) = @_;
#     $stmt->from(
# 	$stmt->LEFT_JOIN_ON(qw(RealmFile guest.RealmUser), [
# 	    ['RealmFile.realm_id', 'guest.RealmUser.realm_id'],
# 	    ['guest.RealmUser.role', ['GUEST']],
#         ]),
# 	$stmt->INNER_JOIN_ON(qw(guest.RealmUser guest.RealmOwner), [
# 	    ['guest.RealmUser.user_id', 'guest.RealmOwner.realm_id'],
# 	]),
#     );
#     return shift->SUPER::internal_prepare_statement(@_);
# }

1;
