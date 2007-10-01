# Copyright (c) 2003 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::Text::Widget::CSV;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Util::CSV;

# C<Bivio::UI::Text::Widget::CSV> creates a csv table from HTMLWidget.Table
# specifications.
#
# Extracts the cells and summary cells and produces a table.
#
#
#
# column_control : value
#
# A widget value which, if set, must be a true value to render the column.
#
# column_heading : string
#
# The heading label to use for the columns heading. By default, the column
# field name is used to look up the heading label from the facade.
#
# columns : array_ref (required)
#
# List of fields to render. Individual columns may optionally be array_refs
# including an attributes hash_ref with a I<column_heading> value.
#
# list_class : string (required)
#
# The class name of the list model to be rendered. The list_class is used to
# determine the column cell types for the table.  If the model I<has_iterator>,
# will use the iterator to render the rows.
#
# header : array_ref
#
# Header widger to be rendered at the top of the file.
#
# type : Bivio::Type
#
# The field type to use for rendering. By default, the column field name is
# used to look up the type from the list model.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    # Renders the table.
    #
    # Calls
    # L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
    # as application/csv
    return $self->execute_with_content_type($req, 'text/csv');
}

sub initialize {
    my($self) = @_;
    # Reads cells and makes sure the fields exist.
    my($list) = Bivio::Biz::Model->get_instance($self->get('list_class'));
    foreach my $col (@{$self->get('columns')}) {
        $col = [$col, {}]
            unless ref($col) eq 'ARRAY';
	# Make sure we can convert a value to a string.
	$list->get_field_type($col->[0])->to_string(undef);
    }
    $self->unsafe_initialize_attr('header');
    return;
}

sub internal_new_args {
    my(undef, $list_class, $columns, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"list_class" must be a defined scalar'
	unless defined($list_class) && !ref($list_class);
    return '"columns" must be an array_ref'
	unless ref($columns) eq 'ARRAY';
    return {
	list_class => $list_class,
	columns => $columns,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    return $self;
}

sub render {
    my($self, $source, $buffer) = @_;
    if ($self->unsafe_get('header')) {
        $self->unsafe_render_attr('header', $source, $buffer);
	$$buffer .= "\n\n";
    }
    my($list) = $source->get_widget_value(
	ref(Bivio::Biz::Model->get_instance($self->get('list_class'))));

    my($render_columns) = {
        map(($_->[0] => 1), grep(_get_column_control($self, $_, $list),
            @{$self->get('columns')})),
    };
    $$buffer .= ${Bivio::Util::CSV->to_csv_text([
	map({_get_column_heading($_, $list, $source->get_request)}
            grep($render_columns->{$_->[0]}, @{$self->get('columns')}))])};
    my($method) = $list->has_iterator
	? 'iterate_next_and_load' : ('next_row', $list->reset_cursor);
    while ($list->$method()) {
	$$buffer .= ${Bivio::Util::CSV->to_csv_text([
	    map({_get_column_value($_, $list)}
                grep($render_columns->{$_->[0]}, @{$self->get('columns')}))])};
    }
    return;
}

sub _get_column_control {
    my($self, $it, $list) = @_;
    my($control) = $it->[1]->{'column_control'};
    return $self->unsafe_resolve_widget_value($control, $list)
        if $control;
    return 1;
}

sub _get_column_heading {
    my($it, $list, $req) = @_;
    my($heading) = $it->[1]->{column_heading};
    return defined($heading)
        ? $heading
        : Bivio::UI::Text->get_value(
            $list->simple_package_name, $it->[0], $req);
}

sub _get_column_value {
    my($it, $list) = @_;
    return ($it->[1]->{type} || $list->get_field_type($it->[0]))
        ->to_string($list->get($it->[0]));
}

1;
