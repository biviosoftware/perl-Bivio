# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::RadioGrid;
use strict;
$Bivio::UI::HTML::Widget::RadioGrid::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::RadioGrid - create a grid of radio buttons

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::RadioGrid;
    Bivio::UI::HTML::Widget::RadioGrid->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Grid>

=cut

use Bivio::UI::HTML::Widget::Grid;
@Bivio::UI::HTML::Widget::RadioGrid::ISA = ('Bivio::UI::HTML::Widget::Grid');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::RadioGrid> create a grid of radio
buttons.  The grid is shaped according to the length and width
of the buttons.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item choices : Bivio::Type::Enum (required)

List of choices will be constructed from the Enum's values.

=item show_unknown : boolean [1]

Should the UNKNOWN type be displayed?

=back

=cut

#=IMPORTS
use Bivio::Type::Enum;
use Bivio::UI::HTML::Widget::Radio;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::RadioGrid

Set up the grid.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::Grid::new(@_);
    my($field) = $self->get('field');
    my($choices) = $self->get('choices');

    # Only allow Enum right now
    Bivio::IO::Alert->die($choices, ': not supported choices')
		unless UNIVERSAL::isa($choices, 'Bivio::Type::Enum');

    # Convert to Radio
    my(@items) = map {
	Bivio::UI::HTML::Widget::Radio->new({
	    field => $field,
	    value => $_->[0],
	    label => $_->[1],
	}),
    } @{_load_items_from_enum($self, $choices)};

    # Layout the buttons
    $self->layout_buttons(\@items, $choices->get_width_long_desc);
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

# _load_items_from_enum(Bivio::Type::Enum enum) : array_ref
#
# Loads items from the enum choices attribute. Enum values are static
# so this is called during initialize.
#
#TODO: MERGE WITH Select
sub _load_items_from_enum {
    my($self, $enum) = @_;
    return _load_items_from_enum_list($self, [$enum->get_list]);
}

# _load_items_from_enum_list(array_ref list) : array_ref
#
# Creates "items" from "list" of enum values.  Helper to _load_items_from_enum
# and _load_items_from_enum_set.
#
sub _load_items_from_enum_list {
    my($self, $list) = @_;
    # Sort
    my(@values) = sort {
	# Always put "0" (unknown) first.
	$a->as_int <=> $b->as_int;
    } @$list;

    shift(@values) unless $self->get_or_default('show_unknown', 1);

    # id, display pairs
    my(@items);
    foreach my $item (@values) {
	push(@items, [$item, Bivio::Util::escape_html($item->get_long_desc)]);
    }

    # Result
    return \@items;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
