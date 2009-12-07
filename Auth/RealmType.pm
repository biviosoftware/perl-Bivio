# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
use Bivio::Base 'Type.EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile;
my($_S) = b_use('Type.String');
my($_I) = b_use('Type.Integer');

sub as_default_owner_id {
    return shift->as_int;
}

sub as_default_owner_name {
    return lc(shift->get_name);
}

sub as_property_model_class_name {
    return $_S->to_camel_case_identifier(shift->get_name);
}

sub equals_or_any_group_check {
    my($self, $match) = @_;
    $match ||= $self->ANY_GROUP;
    return $self == $match
	|| $match->eq_any_group && grep($self == $_, $self->get_any_group_list)
	? 1 : 0;
}

sub get_any_group_list {
    return grep($_->is_group, shift->get_non_zero_list);
}

sub is_default_id {
    my($proto, $id) = @_;
    $id = $_I->from_literal_or_die($id);
    return grep($id == $_->as_default_owner_id, $proto->get_non_zero_list)
	? 1 : 0;
}

sub is_group {
    return shift->equals_by_name(qw(GENERAL)) ? 0 : 1;
}

sub self_or_any_group {
    my($self) = @_;
    return [$self->eq_any_group ? $self->get_any_group_list : $self];
}

1;
