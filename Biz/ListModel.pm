# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
$Bivio::Biz::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::ListModel - An abstract model of multi row values.

=head1 SYNOPSIS

    use Bivio::Biz::ListModel;
    Bivio::Biz::ListModel->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::ListModel::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::ListModel>

=cut

=head1 CONSTANTS

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
	column_info => $column_info,
	rows => []
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
    return scalar(@{$fields->{column_info}});
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
The sort param must be of the form: sort(a|d<col>). If the specified column
doesn't support sorting, then '' is returned.

=cut

sub get_order_by {
    my($self, $fp) = @_;

    my($order_by) = '';
    my($sort) = $fp->get('sort') || '';

    # make sure it is in correct form and col is in range
    if ($sort =~ /(a|d)(\d+)/ and $2 >= 0 and $2 < $self->get_column_count()) {
	if ($self->get_sort_key($2)) {
	    $order_by = ' order by '.$self->get_sort_key($2);
	    $order_by .= ' desc' if $1 eq 'd';
	}
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

    return scalar(@{$fields->{rows}});
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

=head2 get_value_at(int row, int col) : scalar or CompoundField

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
