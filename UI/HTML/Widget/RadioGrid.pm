# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::RadioGrid;
use strict;
$Bivio::UI::HTML::Widget::RadioGrid::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::RadioGrid::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::RadioGrid - create a grid of radio buttons

=head1 RELEASE SCOPE

bOP

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

=item auto_submit : boolean [0]

Should the a click submit the form?

=item choices : Bivio::Type::Enum (required)

List of choices will be constructed from the Enum's values.

=item choices : Bivio::TypeValue (required)

List of choices will be constructed from the Enum (type) and an
array_ref (value) containing the enum's values.  Doesn't support
EnumSets, but could be made to.  This format is more convenient
for the problem I have right now.

If an element in the array_ref is a hash_ref, it can set atttributes
on the radio button, e.g. I<control> and I<value>.

The I<control> will be set to the choice, if the choice type is
a TaskId.  See ControlBase.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item column_count : int [undef]

If defined, forces the number of columns to a fixed width.

=item show_unknown : boolean [1]

Should the UNKNOWN type be displayed?

=item want_text : boolean [0]

Lookup the names of the grid values using L<Bivio::UI::Text|Bivio::UI::Text>.
Will prefix with RadioGrid.  Only works if I<column_count> is defined.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;
use Bivio::Type::Enum;
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::UI::HTML::Widget::Radio;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::RadioGrid

Set up the grid.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    my($field) = $self->get('field');
    my($choices) = $self->get('choices');

    # Only allow Enum right now
    my($items);
    if (UNIVERSAL::isa($choices, 'Bivio::Type::Enum')) {
	$items = _load_items_from_enum($self, $choices);
    }
    elsif ($choices->isa('Bivio::TypeValue')
	   && $choices->get('type')->isa('Bivio::Type::Enum')
	   && ref($choices->get('value')) eq 'ARRAY') {
	$items = _load_items_from_enum_array($self, $choices);
    }
    elsif ($choices->isa('Bivio::TypeValue')
	   && $choices->get('type')->isa('Bivio::Type::String')
	   && ref($choices->get('value')) eq 'ARRAY') {
	$items = _load_items_from_string_array($self, $choices);
    }
    else {
	Bivio::Die->die($choices, ': unsupported choices type');
    }

    my($cc) = $self->unsafe_get('column_count');
    my($wtl) = $self->get_or_default('want_text', 0);
    my($max_width) = 0;
    # Convert to Radio
    my(@items) = map {
	Bivio::UI::HTML::Widget::Radio->new({
	    field => $field,
	    value => $_->[0],
	    label => _max_width(\$max_width,
		$wtl ? $_VS->vs_text('radiogrid', $_->[0]->get_name)
		: $_->[1]),
	    auto_submit => $self->get_or_default('auto_submit', 0),
	    %{$_->[2]},
	});
    } @$items;

    # Layout the buttons
    if ($cc) {
	$self->layout_buttons_row_major(\@items, $cc);
    }
    else {
	$self->layout_buttons(\@items, $max_width);
    }
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
	push(@items, [$item, $item->get_long_desc, {}]);
    }

    # Result
    return \@items;
}

# _load_items_from_enum_array(Bivio::UI::HTML::Widget::Select self, Bivio::TypeValue choices) : array
#
# Loads the items from an array_ref which contains enums or enum names/ints.
# Keeps order.
#
sub _load_items_from_enum_array {
    my($self, $choices) = @_;
    my($type, $value) = $choices->get('type', 'value');
    return [
	map {
	    my($attrs) = ref($_) eq 'HASH' ? $_ : {value => $_};
	    my($e) = $type->from_any($attrs->{value});
	    # Control is a task if it is just a string
	    $attrs->{control} = $e->get_name
		    if $type->isa('Bivio::Agent::TaskId')
			    && !$attrs->{control};
	    # Don't apply 'value' to the widget
	    delete($attrs->{value});
	    [
		$e,
		$e->get_long_desc,
		$attrs,
	    ];
	} @$value
    ];
}

# _load_items_from_string_array(Bivio::UI::HTML::Widget::Select self, Bivio::TypeValue choices)
#
# Loads the items from an array_ref which contains strings
# Keeps order.
#
sub _load_items_from_string_array {
    my($self, $choices) = @_;
    my($i) = 1;
    return [map {[$i++, $_, {}]}
	@{$choices->get('value')}];
}

# _max_width(int_ref max, string label) : string
#
# Updates $$max and returns label.
#
sub _max_width {
    my($max, $label) = @_;
    $$max = length($label) if $$max < length($label);
    return $label;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
