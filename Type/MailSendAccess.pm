# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailSendAccess;
use strict;
use Bivio::Base 'Type.Enum';

my($_CATEGORY_PREFIX) = 'mail_send_access_';
__PACKAGE__->compile([
    UNKNOWN => [0, 'Select who can send mail'],
    ALL_GUESTS => [1, 'Guests and members can send mail'],
    ALL_MEMBERS => [2, 'Only group members can send mail'],
    ALL_ADMINS => [3, 'Only adminstrators can send mail'],
    ALL_USERS => [4, 'Any registered user can send mail'],
    EVERYBODY => [5, 'Anybody (even non-users) can send mail'],
    NOBODY => [6, 'Nobody (not even admins) can send mail'],
]);
b_use('IO.Config')->register(my $_CFG = {
    default => 'ALL_MEMBERS',
});

sub as_realm_role_category {
    return $_CATEGORY_PREFIX . shift->as_realm_role_category_role_group;
}

sub as_realm_role_category_role_group {
    return lc(shift->get_name);
}

sub from_realm_role_enabled_categories {
    my($proto, $enabled_categories) = @_;
    my($modes) = [map(
	$_ =~ /^$_CATEGORY_PREFIX(.+)/o ? $1 : (),
	@$enabled_categories,
    )];
    b_die($modes, ': must be exactly one enabled mode')
	unless @$modes == 1;
    return $proto->from_name($modes->[0]);
}

sub get_default {
    return $_CFG->{default};
}

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG->{default} = $proto->from_any($cfg->{default});
    return;
}

1;
