# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotType;
use strict;
use Bivio::Base 'Model.RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TS) = Bivio::Type->get_instance('TupleSlot');
my($_TSA) = Bivio::Type->get_instance('TupleSlotArray');

sub LIST_FIELDS {
    return [map(
	"TupleSlotType.$_", qw(label type_class choices default_value))];
}

sub DEFAULT_CLASS {
    return 'String';
}

sub create {
    _assert_values(@_);
    return shift->SUPER::create(@_);
}

sub create_from_hash {
    my($self, $types) = @_;
    while (my($label, $values) = each(%$types)) {
	$values->{label} = $label;
	$self->create({map(
	    ($_ => $self->get_field_type($_)->from_literal_or_die(
		$values->{$_}, 1)),
	    qw(label type_class choices default_value),
	)});
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'tuple_slot_type_t',
	columns => {
	    tuple_slot_type_id => ['PrimaryId', 'PRIMARY_KEY'],
	    label => ['TupleSlotLabel', 'NOT_NULL'],
	    type_class => ['SimpleClassName', 'NOT_NULL'],
	    choices => ['TupleSlotArray', 'NONE'],
	    default_value => ['TupleSlot', 'NONE'],
        },
    });
}

sub type_class_instance {
    my($proto, $model, $prefix) = @_;
    return Bivio::Type->get_instance(
	_class($proto, $model->get($prefix . 'type_class')));
}

sub update {
    my($self, $values, @rest) = @_;
    my($v) = {%{$self->get_shallow_copy}, %$values};
    _assert_values($self, $v);
    return $self->SUPER::update($v, @rest);
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
	unless defined($v)
	and (my $c = $model->get($prefix . 'choices'))->is_specified;
    return @{$c->map_iterate(sub {$t->is_equal($v, $_[0]) ? 1 : ()})}
	? ($v, undef)
	: (undef, Bivio::TypeError->NOT_FOUND);
}

sub _assert_values {
    my($self, $values) = @_;
    my($mock) = Bivio::Collection::Attributes->new({%$values});
    defined($values->{label})
	or _err($self, label => 'NULL');
    defined($values->{type_class})
	or _err($self, type_class => 'NULL');
    _err($self, type_class => 'SIMPLE_CLASS_NAME')
	unless Bivio::IO::ClassLoader->unsafe_map_require(
	    'Type', _class($self, $values->{type_class}),
	);
    if ($values->{choices}->is_specified) {
	$mock->put(choices => $values->{choices}->new([]));
	my($seen) = {};
	$mock->put(choices => $values->{choices} = $_TSA->new(
	    $values->{choices}->map_iterate(
		sub {
		    my($c) = @_;
		    my($v, $e) = $self->validate_slot($c, $mock);
		    _err($self, choices => $e)
			if $e;
		    return unless defined($v);
		    $seen->{$v}++ and _err($self, choices => 'EXISTS');
		    return $v;
		},
	    ),
	));
    }
    if (defined($values->{default_value})) {
	my($v, $e) = $self->validate_slot($values->{default_value}, $mock);
	_err($self, default_value => $e)
	    if $e;
	$values->{default_value} = $v;
    }
    return;
}

sub _class {
    my($proto, $c) = @_;
    return $c eq $proto->DEFAULT_CLASS ? 'TupleSlot' : $c;
}

sub _err {
    my($self, $field, $err) = @_;
    Bivio::Die->throw(DB_CONSTRAINT => {
	type_error => Bivio::TypeError->from_any($err),
	table => $self->get_info('table_name'),
	columns => [$field],
    });
    # DOES NOT RETURN
}

1;
