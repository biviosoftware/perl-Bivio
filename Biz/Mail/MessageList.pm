# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::MessageList;
use strict;
use Carp();
$Bivio::Biz::Mail::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Mail::MessageList - A list of mail messages.

=head1 SYNOPSIS

    use Bivio::Biz::Mail::MessageList;
    Bivio::Biz::Mail::MessageList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

@Bivio::Biz::Mail::MessageList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Mail::MessageList>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Mail::MessageList



=cut

sub new {
    my($self) = &Bivio::Biz::ListModel::new(@_);
    $self->{$_PACKAGE} = {
	row_count => 0,
	values => [],

	#TODO: store actions in static field
	actions => {
#	    up => Bivio::Biz::UpAction->new(),
#	    down => Bivio::Biz::DownAction->new(),
#	    compose => Bivio::Biz::Mail::ComposeAction->new()
	}
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 find(FindParams p) : boolean

Loads the model using values from the specified FindParams.
Returns 1 if successful, or 0 if no data was loaded.

=cut

sub find {
    my($self, $params) = @_;
    my($fields) = $self->{$_PACKAGE};

    die("not implemented");
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action.

=cut

sub get_action {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    return $fields->{actions}->{$name};
}

=for html <a name="get_action_names"></a>

=head2 get_action_names() : array

Returns an array of model actions names.

=cut

sub get_action_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return keys(%{$fields->{actions}});
}

=for html <a name="get_column_count"></a>

=head2 get_column_count() : int

Returns the number of columns in the list.

=cut

sub get_column_count {
    return 3;
}

=for html <a name="get_column_descriptor"></a>

=head2 get_column_descriptor(int col) : FieldDescriptor

Returns the FieldDescriptor for the specified column.

=cut

sub get_column_descriptor {
    my($self, $col);

    return Bivio::Biz::FieldDescriptor::MODEL_REF() if $col == 0;
    return Bivio::Biz::FieldDescriptor::EMAIL_REF() if $col == 1;
    return Bivio::Biz::FieldDescriptor::DATE() if $col == 2;

    Carp::croak("invalid column $col");
}

=for html <a name="get_column_heading"></a>

=head2 get_column_heading(int col) : string

Returns the column heading for the specified column.

=cut

sub get_column_heading {
    my($self, $col);

    return 'Subject' if $col == 0;
    return 'From' if $col == 1;
    return 'Date' if $col == 2;

    Carp::croak("invalid column $col");
}

=for html <a name="get_index"></a>

=head2 get_index() : int

Returns the index of the first item into the result set.

=cut

sub get_index {
    die("not implemented");
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the total number of rows in the query.

=cut

sub get_result_set_size {
    die("not implemented");
}

=for html <a name="get_row_count"></a>

=head2 get_row_count() : int

Returns the number of rows in the result set.

=cut

sub get_row_count {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{row_count};
}

=for html <a name="get_value_at"></a>

=head2 get_value_at(int row, int col) : scalar or CompoundField

Returns the value at the specified row, col cooridate.

=cut

sub get_value_at {
    my($self, $row, $col) = @_;
    my($fields) = $self->{$_PACKAGE};
    $col < $self->get_column_count() || Carp::croak("invalid col $col");
    $row < $self->get_row_count() || Carp::croak("invalid row $row");
    return $fields->{values}->[$row][$col];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
