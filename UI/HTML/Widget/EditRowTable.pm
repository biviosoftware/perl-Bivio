# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::EditRowTable;
use strict;
$Bivio::UI::HTML::Widget::EditRowTable::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::EditRowTable::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::EditRowTable - UI editor for EditRowFormModel

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::EditRowTable;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Table>

=cut

use Bivio::UI::HTML::Widget::Table;
@Bivio::UI::HTML::Widget::EditRowTable::ISA = ('Bivio::UI::HTML::Widget::Table');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::EditRowTable> UI editor for EditRowFormModel

=head1 ATTRIBUTES

=over 4

=item form_class : string (required)

The class name of the source form.  The
C<Bivio::Biz::Model::> prefix will be inserted if need be.

=back

=head1 CELL ATTRIBUTES

=over 4

=item column_selectable : boolean [false]

If true, an widget will be rendered for the selected row/column using
the form as the source.

=item column_edit_widget : Bivio::UI::HTML::Widget

The widget which will be used to render the column for the selected row
editor. Overrides the default from the widget factory. If present, then
column_selectable is forced.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::HTML::Widget::EditRowSelector;
use Bivio::UI::HTML::Widget::FormFieldError;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::HTML::Widget::EditRowTable

Creates a new EditRowTable.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::Table::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create_cell"></a>

=head2 create_cell(Bivio::Biz::Model model, string col, hash_ref attrs) : Bivio::UI::HTML::Widget

Overrides Table->create_cell to create a corresponding edit widget if
necessary.

=cut

sub create_cell {
    my($self, $model, $col, $attrs) = @_;
    my($fields) = $self->{$_PACKAGE};

    # create the display cell
    my($cell) = $self->SUPER::create_cell($model, $col, $attrs);
    my($form) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('form_class'));

    # if the column is selectable or has an edit widget,
    # then call the superclass again to create an editable cell
    if ($attrs->{column_selectable} || $attrs->{column_edit_widget}) {
	# use the edit widget if present
	if ($attrs->{column_edit_widget}) {
	    $attrs->{column_widget} = $attrs->{column_edit_widget};
	}

	# for display widgets, use the form as the source (not the list)
	$attrs->{field} = [['->get_request'], ref($form), $col]
		if $col && $attrs->{wf_want_display};

	my($edit_cell) = $self->SUPER::create_cell($form, $col, $attrs);

	# wrap with an error displaying widget
	if ($col) {
	    $edit_cell = $self->join(
		    Bivio::UI::HTML::Widget::FormFieldError->new({
			field => $col,
		    }),
		    $edit_cell);
	    $edit_cell->put(parent => $self);
	    $edit_cell->initialize;
	}

	# get references between display and edit cells
	# used to swap and restore cells during render.

	# NOTE: this creates a circular reference which will not be
	# garbage collected - probably OK for UI widgets created only
	# during initialization

	_trace('circular dependency ', $cell->unsafe_get('field')) if $_TRACE;
	$edit_cell->put(cell => $cell);
	$cell->put(edit_cell => $edit_cell);
    }

    return $cell;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};

    unshift(@{$self->get('columns')}, ['', {
	column_widget => Bivio::UI::HTML::Widget::EditRowSelector->new({}),
    }]);
    $self->SUPER::initialize;

    return;
}

=for html <a name="render_row"></a>

=head2 render_row(array_ref cells, any source, string_ref buffer)

=head2 render_row(array_ref cells, any source, string_ref buffer, string row_prefix, boolean fix_space)

Highlights the row, if selected.

=cut

sub render_row {
    my($self, $cells, $source, $buffer, $row_prefix, $fix_space) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($unwrap) = 0;
    my($form) = $source->get_request->get($self->ancestral_get('form_class'));

    my($selected_row) = $form->get('selected_row');
    if (defined($selected_row) && $selected_row == $source->get_cursor) {
#TODO: use resource for color
	$row_prefix = "\n<tr bgcolor=#FFCC33>";

	foreach my $cell (@$cells) {
	    my($edit_cell) = $cell->unsafe_get('edit_cell');
	    next unless $edit_cell;
	    $cell = $edit_cell;
	}
	$unwrap = 1;
    }

    $self->SUPER::render_row($cells, $source, $buffer, $row_prefix,
	    $fix_space);

    if ($unwrap) {
	foreach my $edit_cell (@$cells) {
	    my($cell) = $edit_cell->unsafe_get('cell');
	    next unless $cell;
	    $edit_cell = $cell;
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
