# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::LaTeX::Widget::Table;
use strict;
$Bivio::UI::LaTeX::Widget::Table::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::LaTeX::Widget::Table::VERSION;

=head1 NAME

Bivio::UI::LaTeX::Widget::Table - renders a ListModel as LaTeX

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::LaTeX::Widget::Table;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::LaTeX::Widget::Table::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::LaTeX::Widget::Table> is for simple tabular data. It does
not render the table headings or the table start/end tags.

=head1 TABLE ATTRIBUTES

=over 4

=back

=item columns : array_ref (required)

The column names to display, in order. Column headings will be assigned
by looking up (simple list class, field).

Each column element is specified in one of the following forms:

Just the field name of the list model:

    <field_name>

=item list_class : string (required)

The class name of the list model to be rendered. The list_class is used
to determine the column cell types for the table.

=back

=cut

#=IMPORTS
use Bivio::UI::LaTeX::Widget::String;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::LaTeX::Widget::Table

Creates a new Table instance.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];

    $fields->{cells} = [];
    foreach my $column (@{$self->get('columns')}) {
        my($cell) = Bivio::UI::LaTeX::Widget::String->new([$column]);
        $self->initialize_value('cell ' . $column, $cell);
        push(@{$fields->{cells}}, $cell);
        push(@{$fields->{cells}}, ' & ');
    }
    # remove the last '&'
    pop(@{$fields->{cells}});

    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

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

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the table upon the output buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($list) = $req->get('Model.' . $self->get('list_class'));

    $list->reset_cursor;
    while ($list->next_row) {
        foreach my $cell (@{$fields->{cells}}) {
            if (ref($cell)) {
                $cell->render($list, $buffer);
            }
            else {
                $$buffer .= $cell;
            }
        }
        $$buffer .= " \\\\ \n";
    }
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
