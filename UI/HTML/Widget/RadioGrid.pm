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

=back

=cut

#=IMPORTS
use Bivio::Type::Enum;
use Bivio::UI::HTML::Widget::Radio;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


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
    } @{_load_items_from_enum($choices)};

    #
    my($width) = $choices->get_width_long_desc;
    my(@rows) = ();
    my($s) = '&nbsp;' x 3;

    # Max 4 items across in one row
    if (int(@items) * $width < 60 && int(@items) <= 4) {
	my(@items) = map {($_, $s)} @items;
	pop(@items);
	push(@rows, \@items);
    }
    elsif ($width < 20) {
	my($third) = int((int(@items) + 2)/3);
	for (my($i) = 0; $i < $third; $i++) {
	    push(@rows, [$items[$i],
		$s, $items[$i+$third] || $s,
		$s, $items[$i+2*$third] || $s]);
	}
    }
    elsif ($width < 30) {
	my($half) = int((int(@items) + 1)/2);
	for (my($i) = 0; $i < $half; $i++) {
	    push(@rows, [$items[$i], $s, $items[$i+$half] || $s]);
	}
    }
    else {
	push(@rows, [shift(@items)]) while @items;
    }

    # Set up the grid
    $self->put(values => \@rows);
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
    my($enum) = @_;
    return _load_items_from_enum_list([$enum->get_list]);
}

# _load_items_from_enum_list(array_ref list) : array_ref
#
# Creates "items" from "list" of enum values.  Helper to _load_items_from_enum
# and _load_items_from_enum_set.
#
sub _load_items_from_enum_list {
    my($list) = @_;
    # Sort
    my(@values) = sort {
	# Always put "0" (unknown) first.
	$a->as_int <=> $b->as_int;
    } @$list;

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
