# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
$Bivio::Biz::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel - An abstract model of multi row values.

=head1 SYNOPSIS

    my($list) = ...;

    # print the page range
    print($list->get_index().' - '
            .$list->get_index() + $list->get_row_count() - 1
            .' / '.$list->get_result_set_size()."\n");

    # print the page data
    for (my($row) = 0; $row < $list->get_row_count(); $row++) {
        for (my($col) = 0; $col < $list->get_column_count(); $col++) {
            print($list->get_value_at($row, $col)."\n");
        }
    }

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::ListModel::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::ListModel> is a holder for multi row data sets. It provides
an interface for returning large data sets in mulitple pages. Subclasses
can override L<"get_sort_key"> and L<"get_default_sort_key"> to provide
column sorting information for L<Bivio::UI::HTML::ListView>. ListModels
export column information in the form of L<Bivio::Biz::FieldDescriptor>
through the method L<"get_column_descriptor">.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

#=IMPORTS
use Bivio::Util;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, array column_info) : Bivio::Biz::ListModel

Creates a new ListModel with the specified name and column information.
column_info should have the format:
    [
        ['heading', field-descriptor]
        ...
    }

=cut

sub new {
    my($proto, $name, $column_info) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $name);
    $self->{$_PACKAGE} = {
	'column_info' => $column_info,
	'rows' => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_column_count"></a>

=head2 get_column_count() : int

Returns the number of columns in the model.

=cut

sub get_column_count {
    my($self, $col) = @_;
    my($fields) = $self->{$_PACKAGE};
    return int(@{$fields->{column_info}});
}

=for html <a name="get_column_descriptor"></a>

=head2 get_column_descriptor(int col) : FieldDescriptor

Returns the descriptor for the indexed column.

=cut

sub get_column_descriptor {
    my($self, $col) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{column_info}->[$col][1];
}

=for html <a name="get_column_heading"></a>

=head2 get_column_heading(int col) : string

Returns the heading for the specified column.

=cut

sub get_column_heading {
    my($self, $col) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{column_info}->[$col][0];
}

=for html <a name="get_default_sort_key"></a>

=head2 get_default_sort_key() : string

Returns the sort key to use if no other is specified. This method should
be overridden by subclasses for default sorting in the order by clause.
By default this method returns undef, indicating that no default sorting
exists.

=cut

sub get_default_sort_key {
    return undef;
}

=for html <a name="get_finder_at"></a>

=head2 abstract get_finder_at(int row) : string

Returns the model finder for the specified row. This should be the string
format of a L<Bivio::Biz::FindParams>.

=cut

sub get_finder_at {
    die("abstract method");
}

=for html <a name="get_index"></a>

=head2 get_index() : int

Returns the index of the first item into the result set. Subclasses should
override this if they support paging result sets. By default, this method
returns 0, which indicates the start of the list.

=cut

sub get_index {
    return 0;
}

=for html <a name="get_order_by"></a>

=head2 get_order_by(FindParams fp) : string

Returns the 'order by' clause based on the sort argument in the FindParams.
The sort param must be of the form: sort(a|d<col>). If the model doesn't
support sorting, then '' is returned.

=cut

sub get_order_by {
    my($self, $fp) = @_;

    my($order_by) = '';
    my($sort) = $fp->get('sort') || '';
    my($default_key) = $self->get_default_sort_key() || '';

    # make sure it is in correct form and col is in range
    if ($sort =~ /(a|d)(\d+)/ and $2 >= 0 and $2 < $self->get_column_count()) {
	my($key) = $self->get_sort_key($2);
	if ($key) {
	    $order_by = ' order by '.$key;
	    $order_by .= ' desc' if $1 eq 'd';

	    # add the default key if it isn't already present
	    if ($default_key =~ /^$key/ ) {
	    }
	    else {
		$order_by .= ','.$default_key;
	    }
	}
    }
    if ($order_by eq '' and $default_key) {
	$order_by = ' order by '.$self->get_default_sort_key();
    }
    return $order_by;
}


=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the total number of rows in the query. Subclasses should override
this if they support paging result sets. By default, this method returns
the row count, indicating that all records are displayed.

=cut

sub get_result_set_size {
    my($self) = @_;

    return $self->get_row_count();
}

=for html <a name="get_row_count"></a>

=head2 get_row_count() : int

Returns the number of rows in the model result set.

=cut

sub get_row_count {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return int(@{$fields->{rows}});
}

=for html <a name="get_selected_index"></a>

=head2 get_selected_index() : int

Returns the index of the selected item, or -1 if no item is selected.

=cut

sub get_selected_index {
    return -1;
}

=for html <a name="get_selected_item"></a>

=head2 get_selected_item() : Model

Returns the selected model or undef if none was selected.

=cut

sub get_selected_item {
    return undef;
}


=for html <a name="get_sort_key"></a>

=head2 get_sort_key(int col) : string

Returns the sorting key for the specified column index. This method should
be overridden by subclasses to support sorting a column. If a column
doesn't support sorting, then undef whould be returned. By default, this
method always returns undef.

=cut

sub get_sort_key {
    return undef;
}

=for html <a name="get_value_at"></a>

=head2 get_value_at(int row, int col) : scalar or array

Returns the simple or complex value at the specified coordinates.

=cut

sub get_value_at {
    my($self, $row, $col) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{rows}->[$row]->[$col];
}

=for html <a name="internal_get_rows"></a>

=head2 protected internal_get_rows() : array

Returns the contents of the rows array. Only subclasses may call this
method (enforced).

=cut

sub internal_get_rows {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    caller(0)->isa($_PACKAGE) || Carp::croak("protected method");
    return $fields->{rows};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
