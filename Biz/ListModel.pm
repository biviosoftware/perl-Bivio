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

#=IMPORTS
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(%_CLASS_INFO);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request $req, array column_info) : Bivio::Biz::ListModel

Creates a new ListModel with the specified request and column information.
column_info should have the format:
    [
        ['heading', field-descriptor]
        ...
    }

Associates this model with the request.

=cut

sub new {
    my($proto, $req) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $req);
    my($class) = ref($self);
    _initialize_class_info($class) unless $_CLASS_INFO{$class};
    my($ci) = $_CLASS_INFO{$class};
    $self->{$_PACKAGE} = {
	class_info => $ci,
	rows => [],
    };
#TODO: Is this right?
    # List models are different from PropertyModels in that a load
    # always "succeeds" in the sense that it either "dies" or returns
    # the number of rows.  Therefore, we associate the model now
    # so the specific implementations don't have to do it.
    $req->put(ref($self), $self);
    return $self;
}

=for html <a name="load_from_request"></a>

=head2 static load_from_request(Bivio::Agent::Request req) : Bivio::Biz::ListModel

Loads the model from the request.  If the class is already loaded, just
gets that.

=cut

sub load_from_request {
    my($proto, $req) = @_;
#TODO: Generalize in Model?
    my($class) = ref($proto) || $proto;
    my($self) = $req->unsafe_get($class);
    return $self if $self;
    $self = $class->new($req);
    $self->load(%{$req->get_fields('query',
	    $self->{$_PACKAGE}->{class_info}->{query_fields})});
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_column_count"></a>

=head2 get_column_count() : int

Returns the number of columns in the model.

=cut

sub get_column_count {
    my($ci) = shift->{$_PACKAGE}->{class_info};
    return int(@{$ci->{column_info}});
}

=for html <a name="get_column_descriptor"></a>

=head2 get_column_descriptor(int col) : FieldDescriptor

Returns the descriptor for the indexed column.

=cut

sub get_column_descriptor {
    my($self, $col) = @_;
    my($ci) = $self->{$_PACKAGE}->{class_info};
    return $ci->{column_info}->[$col][1];
}

=for html <a name="get_column_name"></a>

=head2 get_column_name(int col) : string

Returns the heading for the specified column.

=cut

sub get_column_name {
    my($self, $col) = @_;
    my($ci) = $self->{$_PACKAGE}->{class_info};
    return $ci->{column_info}->[$col][0];
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

=for html <a name="get_query_at"></a>

=head2 abstract get_query_at(int row) : hash_ref

Returns the model query for the specified row.

=cut

sub get_query_at {
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

=head2 get_order_by(hash_ref query) : string

Returns the 'order by' clause based on the sort argument in the query.
The sort param must be of the form: sort(a|d<col>). If the model doesn't
support sorting, then '' is returned.

=cut

sub get_order_by {
    my($self, $query) = @_;

    my($order_by) = '';
    my($sort) = $query->{sort} || '';
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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

B<FOR INTERNAL USE ONLY>.

Returns an array_ref of the column info, sql support,
and valid request query fields.

=cut

sub internal_initialize {
    die('abstract method');

}

#=PRIVATE METHODS

sub _initialize_class_info {
    my($class) = @_;
    my($ci) = $class->internal_initialize;
    $_CLASS_INFO{$class} = $ci = {
	column_info => $ci->[0],
	sql_support => $ci->[1],
	query_fields => $ci->[2],
    };
    $ci->{sql_support}->initialize;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
