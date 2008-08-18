# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ListQueryForm;
use strict;
use Bivio::Base 'Model.QuerySearchBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub filter_keys {
    my($self) = @_;
    return [map($_->[0], @{$self->internal_query_fields})];
}

sub get_list_for_field {
    my($proto, $field) = @_;
    # defaults to <Type>List, subclasses can override this
    return $proto->get_instance(
	$proto->get_instance->get_field_type($field)
	    ->simple_package_name . 'List');
}

sub get_select_attrs {
    my($proto, $field) = @_;
    my($t) = $proto->get_instance->get_field_type($field);
    return {
	choices => $t,
	enum_sort => 'as_int',
	field => $field,
    } if $t->isa('Bivio::Type::Enum');
    my($list) = $proto->get_list_for_field($field);
    return {
	field => $field,
	choices => [$list->package_name],
	list_display_field => $list->get_info('order_by_names')->[0],
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
	    map({
		my($n, $t) = @$_;
		+{
		    name =>  $_->[0],
		    form_name => $_->[0],
		    type => $_->[1],
		    default_value => $t->isa('Bivio::Type::Enum')
			? $t->get_default : undef,
		    constraint => 'NONE',
		};
	    } @{$self->internal_query_fields}),
        ],
    });
}

1;
