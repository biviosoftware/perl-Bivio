# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleSlotType;
use strict;
use base 'Bivio::Biz::Model::RealmBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TS) = Bivio::Type->get_instance('TupleSlot');

sub LIST_FIELDS {
    return [map(
	"TupleSlotType.$_",
	qw(label type_class choices default_value is_required))];
}

sub create_from_hash {
    my($self, $types) = @_;
    while (my($label, $values) = each(%$types)) {
	$values->{label} = $label;
	my($v) = {
	    map(($_
	        => $self->get_field_type($_)->from_literal_or_die($values->{$_}, 1)),
		qw(label type_class choices default_value is_required)),
	};
	@{$v->{choices}} = map(
	    $self->validate_slot_or_die(
		$_, Bivio::Collection::Attributes->new({
		    %$v,
		    choices => undef,
		}),
	    ), @{$v->{choices}},
	) if $v->{choices};
	$v->{default_value} = $self->validate_slot_or_die(
	    $v->{default_value}, Bivio::Collection::Attributes->new({%$v}),
	);
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
	    default_value => ['TupleSlot', 'NONE'],
	    is_required => ['Boolean', 'NOT_NULL'],
        },
    });
}

sub validate_slot {
    my($proto, $value, $model, $prefix) = @_;
    $model ||= $proto;
    $prefix ||= '';
    my($t) = Bivio::Type->get_instance($model->get($prefix . 'type_class'));
    my($v, $e) = $t->from_literal($value);
    return (undef, $e)
	if $e;
    return ($model->get($prefix . 'default_value'), undef)
	unless defined($v);
    return ($v, undef)
	unless my $c = $model->get($prefix . 'choices');
    return grep($t->compare($v, $_) == 0, @$c) ? ($v, undef)
	: (undef, Bivio::TypeError->NOT_TUPLE_CHOICE);
}

sub validate_slot_or_die {
    my($v, $e) = shift->validate_slot(@_);
    Bivio::Die->die(validate_slot => \@_, ': ', $e)
        if $e;
    return $v;
}

1;
