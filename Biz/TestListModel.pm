# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::TestListModel;
use strict;
use Bivio::Biz::FieldDescriptor();
use Bivio::Biz::ListModel();
$Bivio::Biz::TestListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::TestListModel - A testing list model.

=head1 SYNOPSIS

    use Bivio::Biz::TestListModel;
    Bivio::Biz::TestListModel->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

@Bivio::Biz::TestListModel::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::TestListModel>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::TestListModel

Creates a new testing ListModel.

=cut

sub new {
    my($self) = &Bivio::Biz::ListModel::new(@_);
    $self->{$_PACKAGE} = {
	row_count => 0,
	index => 1
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(FindParams fp) : boolean

Loads the list using the specified parameters. Query fields may be
'index', ...

=cut

sub find {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{index} = $fp->get_value('index') || 1;
}

=for html <a name="get_column_count"></a>

=head2 get_column_count() : int

Returns the number of columns.

=cut

sub get_column_count {
    return 5;
}

=for html <a name="get_column_descriptor"></a>

=head2 get_column_descriptor(int col) : FieldDescriptor

Returns the field descriptor for the specified column.

=cut

sub get_column_descriptor {
    return Bivio::Biz::FieldDescriptor->lookup(
	    Bivio::Biz::FieldDescriptor::NUMBER(), 16);
}

=for html <a name="get_column_heading"></a>

=head2 get_column_heading(int col) : string

Returns the heading for the specified column.

=cut

sub get_column_heading {
    my($self, $col) = @_;

    return 'x '.($col + 1);
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns the model's heading.

=cut

sub get_heading {
    return "Multiplication Table";
}

=for html <a name="get_index"></a>

=head2 get_index() : int

Returns the index of the first item into the result set.

=cut

sub get_index {
    my($self, $fp) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{index};
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the total number of rows in the query.

=cut

sub get_result_set_size {
    return 1000;
}

=for html <a name="get_row_count"></a>

=head2 get_row_count() : int

Returns the number of rows in the result set.

=cut

sub get_row_count {
    return 10;
}

=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the model's title

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return "Number ".$fields->{index};
}

=for html <a name="get_value_at"></a>

=head2 get_value_at(int row, int col) : scalar or CompoundField

Returns the value at the specified row, col cooridate.

=cut

sub get_value_at {
    my($self, $row, $col) = @_;
    my($fields) = $self->{$_PACKAGE};

    return ($fields->{index} + $row) * ($col + 1);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
