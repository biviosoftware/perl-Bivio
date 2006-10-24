# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotType;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TS) = Bivio::Type->get_instance('TupleSlot');
my($_TSA) = Bivio::Type->get_instance('TupleSlotArray');

sub LIST_FIELDS {
    return [map(
	"TupleSlotType.$_", qw(label type_class choices))];
}

sub create_from_hash {
    my($self, $types) = @_;
    while (my($label, $values) = each(%$types)) {
	$values->{label} = $label;
	my($v) = {
	    map(($_
	        => $self->get_field_type($_)->from_literal_or_die($values->{$_}, 1)),
		qw(label type_class choices)),
	};
	if ($v->{choices}) {
	    my($fake) = Bivio::Collection::Attributes->new(
		{%$v, choices => undef});
	    $v->{choices} = $_TSA->new($v->{choices}->map_iterate(
		sub {$self->validate_slot_or_die(shift(@_), $fake)}));
	}
	$self->create($v);
    }
    return $self;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_slot_type_t',
	columns => {
	    tuple_slot_type_id => ['PrimaryId', 'PRIMARY_KEY'],
	    label => ['TupleLabel', 'NOT_NULL'],
	    type_class => ['SimpleClassName', 'NOT_NULL'],
	    choices => ['TupleSlotArray', 'NONE'],
        },
    });
}

sub type_class_instance {
    my(undef, $model, $prefix) = @_;
    return Bivio::Type->get_instance($model->get($prefix . 'type_class'));
}

sub validate_slot {
    my($proto, $value, $model, $prefix) = @_;
    $model ||= $proto;
    $prefix ||= '';
    my($t) = $proto->type_class_instance($model, $prefix);
    my($v, $e) = $t->from_literal($value);
    return (undef, $e)
	if $e;
    return ($v, undef)
	unless defined($v) and my $c = $model->get($prefix . 'choices');
    return grep($t->compare($v, $_) == 0, @{$c->as_array}) ? ($v, undef)
	: (undef, Bivio::TypeError->NOT_TUPLE_CHOICE);
}

sub validate_slot_or_die {
    my($v, $e) = shift->validate_slot(@_);
    Bivio::Die->die(validate_slot => \@_, ': ', $e)
        if $e;
    return $v;
}

1;
