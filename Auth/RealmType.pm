# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
use Bivio::Base 'Type.EnumDelegator';

__PACKAGE__->compile;
my($_S) = b_use('Type.String');
my($_MIN) = b_use('Type.PrimaryId')->get_min;

sub as_default_owner_id {
    return shift->as_int;
}

sub as_default_owner_name {
    return lc(shift->get_name);
}

sub as_property_model_class_name {
    return $_S->to_camel_case_identifier(shift->get_name);
}

sub equals_or_any_owner_check {
    my($self, $match) = @_;
    $match ||= $self->ANY_OWNER;
    return $self == $match
        || $match->eq_any_owner && grep($self == $_, $self->get_any_owner_list)
        ? 1 : 0;
}

sub get_any_group_list {
    return grep($_->is_group, shift->get_non_zero_list);
}

sub get_any_owner_list {
    return grep($_->is_owner, shift->get_non_zero_list);
}

sub is_default_id {
    my($proto, $id) = @_;
    return $id
        && $id < $_MIN
        && ($proto->unsafe_from_int($id) || return 0)->as_int
        ? 1 : 0;
}

sub is_group {
    return shift->equals_by_name(qw(USER GENERAL)) ? 0 : 1;
}

sub is_owner {
    return shift->equals_by_name(qw(GENERAL)) ? 0 : 1;
}

sub self_or_any_group {
    my($self) = @_;
    # This is a bit subtle.  self_or_any_group means to match any_owner tasks
    # if $self is any_owner, return groups without user.
    return [$self->eq_any_owner ? $self->get_any_group_list : $self];
}

1;
