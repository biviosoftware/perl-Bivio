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

=for html <a name="get_row_count"></a>

=head2 get_row_count() : int

Returns the number of rows in the model result set.

=cut

sub get_row_count {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return scalar(@{$fields->{rows}});
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
