# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::Text::Widget::CSV;
use strict;
$Bivio::UI::Text::Widget::CSV::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::Widget::CSV::VERSION;

=head1 NAME

Bivio::UI::Text::Widget::CSV - creates a CSV from a ListModel

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Text::Widget::CSV;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Text::Widget::CSV::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Text::Widget::CSV> creates a csv table from HTMLWidget.Table
specifications.

Extracts the cells and summary cells and produces a table.

=head1 ATTRIBUTES

=over 4

=item columns : array_ref (required)

List of fields to render.

=item list_class : string (required)

The class name of the list model to be rendered. The list_class is used to
determine the column cell types for the table.  If the model I<has_iterator>,
will use the iterator to render the rows.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string list_class, array_ref columns, hash_ref attributes) : Bivio::UI::Text::Widget::CSV

Creates a new Table with I<list_class>, I<columns>, and optional
I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::Text::Widget::CSV

Creates a new widget.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Renders the table.

Calls
L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as application/csv

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/csv');
}

=for html <a name="initialize"></a>

=head2 initialize()

Reads cells and makes sure the fields exist.

=cut

sub initialize {
    my($self) = @_;
    my($list) = Bivio::Biz::Model->get_instance($self->get('list_class'));
    foreach my $col (@{$self->get('columns')}) {
	# Make sure we can convert a value to a string.
	$list->get_field_type($col)->to_string(undef);
    }
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

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($list) = $source->get_widget_value(
	ref(Bivio::Biz::Model->get_instance($self->get('list_class'))));
    my($method) = $list->has_iterator
	? 'iterate_next_and_load' : ('next_row', $list->reset_cursor);
    $$buffer .= _join([map({
	Bivio::UI::Text->get_value($list->simple_package_name, $_, $req);
    } @{$self->get('columns')})]);
    while ($list->$method()) {
	$$buffer .= _join([map({
	    $list->get_field_type($_)->to_string($list->get($_));
	} @{$self->get('columns')})]);
    }
    return;
}

#=PRIVATE METHODS

# _join(array_ref values) : string
#
# Joins $values in a CSV row
#
sub _join {
    my($values) = @_;
    return join(',',
	(map {
	    if ($_ =~ /[",\n\r]/) {
		$_ =~ s/"/""/g;
		$_ = qq{"$_"};
	    }
	    $_;
	} @$values),
    ) . "\n";
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
