# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Unique;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    my($self) = @_;
    my($name) = 0;
    foreach my $v (@{$self->get('values')}) {
	$self->initialize_value($name++, $v->{value});
    }
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my($self, $values) = @_;
    return '"values" attribute must be an array_ref'
	unless ref($values) eq 'ARRAY';
    my($parent_fields) = [];
    return {
	values => $self->map_by_two(sub {
	    my($field, $widget) = @_;
	    push(@$parent_fields, $field);
	    {
		parent_fields => [@$parent_fields],
	        field => $field,
	        value => $widget,
	    };
	}, $values),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($name) = 0;
    foreach my $v (@{$self->get('values')}) {
	my($parent_fields, $field, $widget) =
	    @$v{qw(parent_fields field value)};
	my($seen) = $source->get_request
	    ->get_if_defined_else_put(_request_key($parent_fields) => {});
	$self->unsafe_render_value($name++, $widget, $source, $buffer)
	    unless $seen->{join('.', map(defined($_) ? $_ : 'undefined',
					 $source->get(@$parent_fields)))}++;
    }
    return;
}

sub _request_key {
    my($parent_fields) = @_;
    return __PACKAGE__ . '(' . join('.', @$parent_fields) . ')';
}

1;
