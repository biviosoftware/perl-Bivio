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

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::Biz::ListModel

Creates a new ListModel with the specified name.

=cut

sub new {
    my($proto, $name) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $name);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_column_count"></a>

=head2 abstract get_column_count() : int

Returns the number of columns in the model.

=cut

sub get_column_count {
    die("abstract method");
}

=for html <a name="get_column_descriptor"></a>

=head2 abstract get_column_descriptor(int col) : FieldDescriptor

Returns the descriptor for the indexed column.

=cut

sub get_column_descriptor {
    die("abstract method");
}

=for html <a name="get_column_heading"></a>

=head2 get_column_heading(int col) : string

Returns the column heading for the specified column.

=cut

sub get_column_heading {
    die("abstract method");
}

=for html <a name="get_row_count"></a>

=head2 abstract get_row_count() : int

Returns the number of rows in the model result set.

=cut

sub get_row_count {
    die("abstract method");
}

=for html <a name="get_value_at"></a>

=head2 abstract get_value_at(int row, int col) : scalar or CompoundField

Returns the simple or complex value at the specified coordinates.

=cut

sub get_value_at {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
