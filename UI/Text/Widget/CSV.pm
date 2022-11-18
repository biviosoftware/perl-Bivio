# Copyright (c) 2003 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::Text::Widget::CSV;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

# C<Bivio::UI::Text::Widget::CSV> creates a csv table from HTMLWidget.Table
# specifications.
#
# Extracts the cells and summary cells and produces a table.
#
# column_control : value
#
# A widget value which, if set, must be a true value to render the column.
#
# column_heading : string, array_ref or Bivio::UI::Widget
#
# The heading label to use for the columns heading. By default, the column
# field name is used to look up the heading label from the facade.
#
# column_widget : array_ref or Bivio::UI::Widget
#
# The widget which renders the column.
#
# columns : array_ref (required)
#
# List of fields to render. Individual columns may optionally be array_refs
# including an attributes hash_ref with a column attributes values.
#
# list_class : string (required)
#
# The class name of the list model to be rendered. The list_class is used to
# determine the column cell types for the table.  If the model I<has_iterator>,
# will use the iterator to render the rows.
#
# header : array_ref or Bivio::UI::Widget
#
# Header widget to be rendered at the top of the file.
#
# type : Bivio::Type
#
# The field type to use for rendering. By default, the column field name is
# used to look up the type from the list model.

my($_CSV) = b_use('ShellUtil.CSV');
my($_M) = b_use('Biz.Model');
my($_VS) = b_use('UI.ViewShortcuts');

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/csv');
}

sub initialize {
    my($self) = @_;
    my($list) = _list_class($self);

    foreach my $col (@{$self->get('columns')}) {
        $col = [$col, {}]
            unless ref($col) eq 'ARRAY';
        $col->[1]->{column_widget} ||= $col->[1]->{type}
            ? [$col->[1]->{type}, '->to_string', [$col->[0]]]
            : ['->get_as', $col->[0], 'to_string'];
        $col->[1]->{column_heading} ||= $_VS->vs_call('Prose', $_VS->vs_text(
            $list->simple_package_name, $col->[0]));

        foreach my $attr (qw(column_widget column_heading)) {
            $self->initialize_value($attr, $col->[1]->{$attr});
        }
    }
    $self->unsafe_initialize_attr('header');
    return;
}

sub internal_new_args {
    my(undef, $list_class, $columns, $attributes) = @_;
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

sub render {
    my($self, $source, $buffer) = @_;

    if ($self->unsafe_get('header')) {
        $self->unsafe_render_attr('header', $source, $buffer);
        $$buffer .= "\n\n";
    }
    my($list);

    if ($self->unsafe_get('want_iterate_start')) {
        $list = _list_class($self)->new($self->req);
        $list->iterate_start(
            $list->can('parse_query_from_request')
                ? $list->parse_query_from_request
                : (),
            );
    }
    else {
        $list = $source->get_widget_value(ref(_list_class($self)));
    }
    my($cells) = [grep(_get_column_control($self,
        $_->[1]->{column_control}, $list), @{$self->get('columns')})];
    _render_cells($self, 'column_heading', $cells, $source, $buffer);
    my($method) = $list->has_iterator
        ? 'iterate_next_and_load' : ('next_row', $list->reset_cursor);

    while ($list->$method()) {
        _render_cells($self, 'column_widget', $cells, $list, $buffer);
    }
    return;
}

sub _get_column_control {
    my($self, $control, $list) = @_;
    return $control ? $self->unsafe_resolve_widget_value($control, $list) : 1;
}

sub _list_class {
    my($self) = @_;
    return $_M->get_instance($self->get('list_class'));
}

sub _render_cell {
    my($self, $name, $source) = @_;
    my($v) = $self->render_simple_value($name, $source);

    if ($v) {
        $v =~ s/\n+$//;
    }
    return $v;
}

sub _render_cells {
    my($self, $name, $cells, $source, $buffer) = @_;
    $$buffer .= ${$_CSV->to_csv_text([
        map(_render_cell($self, $_->[1]->{$name}, $source), @$cells),
    ])};
    return;
}

1;
