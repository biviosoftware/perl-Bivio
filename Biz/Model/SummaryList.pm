# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::SummaryList;
use strict;
$Bivio::Biz::Model::SummaryList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::SummaryList::VERSION;

=head1 NAME

Bivio::Biz::Model::SummaryList - a list model summary

=head1 SYNOPSIS

    use Bivio::Biz::Model::SummaryList;
    Bivio::Biz::Model::SummaryList->new();

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::Model::SummaryList::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Biz::Model::SummaryList> summarizes columns from a list model
and implements a ListModel-like interface so it can be used in Tables.

Note: SummaryList provides a summary only for the values currently loaded
by the source ListModel(s). If it has only loaded a page of data, then only
the page will be summarized.

SummaryList L<get|"get"> will reset the cursor in the ListModel to the
beginning of the list each time a value is requested - don't call this
methods while iterating through the source(s).

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array_ref source) : Bivio::Biz::Model::SummaryList

=head2 static new(array_ref source, hash_ref static_properties) : Bivio::Biz::Model::SummaryList

Creates a summary list which gets data from the specified source ListModel(s).
Sets the static_properties to values supplied.

=cut

sub new {
    my($proto, $source, $static_properties) = @_;
    my($self) = &Bivio::Collection::Attributes::new($proto,
	    $static_properties);
    $self->{$_PACKAGE} = {
	source => $source,
	request => $source->[0]->get_request,
	loaded => 1,
    };
    return $self;
}

=head1 METHODS

=cut

#TODO: export type information from source ListModel(s)

=for html <a name="get"></a>

=head2 get(string key, ...) : (string, ...)

Overrides Attributes get to dynamically create a summary value for the
named column.

=cut

sub get {
    my($self, @keys) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@result) = ();
    foreach my $name (@keys) {
	$self->put($name, _sum($fields->{source}, $name))
		unless $self->has_keys($name);
    }
    return $self->SUPER::get(@keys);
}

=for html <a name="get_cursor"></a>

=head2 get_cursor() : int

Returns the position.  Returns -1 before the list is read and
undef after the list is read.

=cut

sub get_cursor {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    if ($fields->{loaded}) {
	return -1;
    }
    return 0;
}

=for html <a name="get_list_model"></a>

=head2 get_list_model() : self

Returns itself, the list model.

=cut

sub get_list_model {
    return shift;
}

=for html <a name="get_request"></a>

=head2 get_request() : Bivio::Agent::Request

Returns the request associated with this list.

=cut

sub get_request {
    return shift->{$_PACKAGE}->{request};
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the number of rows loaded.

=cut

sub get_result_set_size {
    return 1;
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string param1, ...) : any

Overrides Attributes get_widget_value to dynamically compute summaries.
Generates and stores summary value and uses Attributes.get_widget_value
to do the rest.

=cut

sub get_widget_value {
    my($self, $name, @params) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Only "get" if first source has this key.  "get" does a "put"
    # if need be.
    $self->get($name) if $fields->{source}->[0]->has_keys($name);
    return $self->SUPER::get_widget_value($name, @params);
}

=for html <a name="next_row"></a>

=head2 next_row() : boolean

Summary lists return only one row.

=cut

sub next_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('no cursor') unless defined($fields->{loaded});
    if ($fields->{loaded}) {
	$fields->{loaded} = 0;
	return 1;
    }
    $fields->{loaded} = undef;
    return 0;
}

=for html <a name="reset_cursor"></a>

=head2 reset_cursor()

Places the cursor at the start of the list.

=cut

sub reset_cursor {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{loaded} = 1;
    return;
}

#=PRIVATE METHODS

# _sum(array_ref source, string name) : string
#
# Returns the summed value for all the values for the specified column
# across all the source list models.
#
sub _sum {
    my($source, $name) = @_;

    my($result) = 0;
    foreach my $list (@$source) {
	my($type) = $list->get_field_type($name);
	$list->reset_cursor;
	while ($list->next_row) {
	    $result = $type->add($result, $list->get($name));
	}
	$list->reset_cursor;
    }
    return $result;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
