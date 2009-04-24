# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::SummaryList;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';

# C<Bivio::Biz::Model::SummaryList> summarizes columns from a list model
# and implements a ListModel-like interface so it can be used in Tables.
#
# Note: SummaryList provides a summary only for the values currently loaded
# by the source ListModel(s). If it has only loaded a page of data, then only
# the page will be summarized.
#
# SummaryList L<get|"get"> will reset the cursor in the ListModel to the
# beginning of the list each time a value is requested - don't call this
# methods while iterating through the source(s).

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub get {
    # (self, string, ...) : (string, ...)
    # Overrides Attributes get to dynamically create a summary value for the
    # named column.
    my($self, @keys) = @_;
    my($fields) = $self->[$_IDI];

    foreach my $name (@keys) {
	$self->put($name, $self->internal_sum($fields->{source}, $name))
            unless $self->has_keys($name);
    }
    return $self->SUPER::get(@keys);
}

sub get_cursor {
    # (self) : int
    # Returns the position.  Returns -1 before the list is read and
    # undef after the list is read.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{loaded} ? -1 : 0;
}

sub get_list_model {
    # (self) : self
    # Returns itself, the list model.
    my($self) = @_;
    return $self;
}

sub get_request {
    # (self) : Agent.Request
    # Returns the request associated with this list.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{request};
}

sub get_result_set_size {
    # (self) : int
    # Returns the number of rows loaded.
    return 1;
}

sub get_source_list_model {
    # (self) : Biz.ListModel
    # Returns the (first) source list model for this SummaryList.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{source}->[0];
}

sub get_widget_value {
    # (self, string, ...) : any
    # Overrides Attributes get_widget_value to dynamically compute summaries.
    # Generates and stores summary value and uses Attributes.get_widget_value
    # to do the rest.
    my($self, $name, @params) = @_;
    my($fields) = $self->[$_IDI];
    # Only "get" if first source has this key.  "get" does a "put"
    # if need be.
    $self->get($name) if $fields->{source}->[0]->has_keys($name);
    return $self->SUPER::get_widget_value($name, @params);
}

sub internal_sum {
    # (self, array_ref, string) : string
    # Returns the summed value for all the values for the specified column
    # across all the source list models.
    my($self, $source, $name) = @_;
    my($result) = 0;

    foreach my $list (@$source) {
	$list->reset_cursor;

	while ($list->next_row) {
            next unless $list->get($name);
	    $result = $list->get_field_type($name)->add(
                $result, $list->get($name));
	}
	$list->reset_cursor;
    }
    return $result;
}

sub new {
    # (proto, array_ref) : Model.SummaryList
    # (proto, array_ref, hash_ref) : Model.SummaryList
    # Creates a summary list which gets data from the specified source ListModel(s).
    # Sets the static_properties to values supplied.
    my($proto, $source, $static_properties) = @_;
    my($self) = $proto->SUPER::new($static_properties);
    $self->[$_IDI] = {
	source => $source,
	request => $source->[0]->get_request,
	loaded => 1,
    };
    return $self;
}

sub next_row {
    # (self) : boolean
    # Summary lists return only one row.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('no cursor')unless defined($fields->{loaded});

    if ($fields->{loaded}) {
	$fields->{loaded} = 0;
	return 1;
    }
    $fields->{loaded} = undef;
    return 0;
}

sub reset_cursor {
    # (self) : undef
    # Places the cursor at the start of the list.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{loaded} = 1;
    return;
}

1;
