# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ListQueryForm;
use strict;
use Bivio::Base 'Model.QuerySearchBaseForm';


sub filter_keys {
    my($self) = @_;
    return [qr{^b_\w+$}];
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
    return {
        field => $field,
        choices => [sub {
            my($source, $proto, $field) = @_;
            return $source->req($proto->get_list_for_field($field)
                ->package_name);
        }, $proto, $field],
        list_display_field => $proto->get_list_for_field($field)
            ->get_info('order_by_names')->[0]
                || b_die($field, ': must have at least one order_by'),
    };
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        visible => [
            map({
                my($n, $t, $overrides) = @$_;
                $t = Bivio::Type->get_instance($t);
                +{
                    name =>  $n,
                    form_name => $n,
                    type => $t,
                    default_value => UNIVERSAL::isa($t, 'Bivio::Type::Enum')
                        ? $t->get_default : undef,
                    constraint => 'NONE',
                    %{$overrides || {}},
                };
            } @{$self->internal_query_fields}),
        ],
    });
}

1;
