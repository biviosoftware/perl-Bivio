# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::OrdinalBase;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    my($self, $values) = @_;
    $values->{$self->ORD_FIELD} = $self->internal_next_ord($values)
	unless defined($values->{$self->ORD_FIELD});
    return shift->SUPER::create(@_);
}

sub internal_next_ord {
    my($self, $values) = @_;
    $values ||= {};
    if ($values->{realm_id}) {
	$self->die($values, ': realm_id must be auth_id')
	    unless $self->req('auth_id') eq $values->{realm_id};
    }
    else {
	$values->{realm_id} = $self->req('auth_id');
    }
    $self->get_instance('Lock')->execute_unless_acquired($self->req);
    my($v) = $self->unsafe_max_ord($values);
    my($t) = $self->get_field_type($self->ORD_FIELD);
    return defined($v) ? $t->add($v, 1) : $t->get_min;
}

sub internal_prepare_max_ord {
    my($self, $stmt, $values) = @_;
    return $stmt->select(
	'MAX(' . $self->get_qualified_field_name($self->ORD_FIELD) . ')',
    )->where([
	$self->get_qualified_field_name('realm_id'),
	[$values->{realm_id}],
    ]);
}

sub unsafe_max_ord {
    my($self, $values) = @_;
    return Bivio::SQL::Connection->execute_one_row(
	$self->internal_prepare_max_ord(Bivio::SQL::Statement->new, $values)
	    ->build_for_list_support_prepare_statement(
		$self->internal_get_sql_support,
	    ),
    )->[0];
}

1;
