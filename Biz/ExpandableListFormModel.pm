# Copyright (c) 1999-2002 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ExpandableListFormModel;
use strict;
$Bivio::Biz::ExpandableListFormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::ExpandableListFormModel::VERSION;

=head1 NAME

Bivio::Biz::ExpandableListFormModel - list form which can have extra rows

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::ExpandableListFormModel;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::Biz::ExpandableListFormModel::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::ExpandableListFormModel> list form which can have extra rows

=cut


=head1 CONSTANTS

=cut

=for html <a name="ROW_INCREMENT"></a>

=head2 ROW_INCREMENT : int

number of empty rows to add to the list.

=cut

sub ROW_INCREMENT {
    return 4;
}

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ExpandableListFormModel

Creates a new ExpandableListFormModel.


=cut

sub new {
    my($proto, @args) = @_;
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {
	list_initialized => 0,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="internal_load_field"></a>

=head2 internal_load_field(string form_field, string list_field)

Loads I<form_field> from the list model's I<list_field> (defaults to
(I<form_field>), or from the request values depending on whether the task was
redirected through add_rows.

=cut

sub internal_load_field {
    my($self, $form_field, $list_field) = @_;
    $list_field ||= $form_field;
    my($list) = $self->get_list_model;
    my($rows) = $self->get_request->unsafe_get(ref($self) . '.rows');

    my($value) = defined($rows)
	    ? $rows->[$list->get_cursor]->{$list_field}
	    : $list->get($list_field);
    $self->internal_put_field($form_field, $value) if defined($value);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	visible => [
	    {
		name => 'add_rows',
		type => 'OKButton',
		constraint => 'NONE',
	    },
	],
	hidden => [
	    {
		name => 'empty_row_count',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="internal_initialize_list"></a>

=head2 internal_initialize_list() : Bivio::Biz::ListModel

Appends empty rows to the list.

=cut

sub internal_initialize_list {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($list) = $self->SUPER::internal_initialize_list();
    return if $fields->{list_initialized};
    $fields->{list_initialized} = 1;
    my($req) = $self->get_request;
    my($form) = $req->get('form');
    my($empty_row_count) = $req->unsafe_get(ref($self) . '.empty_row_count');
    unless ($empty_row_count) {
	if ($form) {
#TODO: Need some validation here, I think?
	    $empty_row_count = $form->{
		$self->get_field_name_for_html('empty_row_count')};
	}
	else {
	    # default number of rows to add
	    $empty_row_count = $self->ROW_INCREMENT;
	}
    }
    $self->internal_put_field('empty_row_count', $empty_row_count);
    $form->{$self->get_field_name_for_html('empty_row_count')}
	    = $empty_row_count;

    $list->append_empty_rows($empty_row_count);
    return $list;
}

=for html <a name="validate"></a>

=head2 validate()

Responds to button click on 'add_rows', save the values on the
request and redirects to the same task.

=cut

sub validate {
    my($self) = shift;
    return $self->SUPER::validate(@_)
	unless defined($self->unsafe_get('add_rows'));
    # increment the empty_row count and redirect to the same task
    my($req) = $self->get_request;
    my($rows) = [];
    $self->reset_cursor;
    while ($self->next_row) {
	# make a copy of the current values
	push(@$rows, $self->get_shallow_copy);
    }
    $self->reset_cursor;
    $req->put_durable(
	ref($self) . '.rows' => $rows,
	ref($self) . '.empty_row_count' =>
	    $self->get('empty_row_count') + $self->ROW_INCREMENT,
    );
    # Put last for testing
    $req->server_redirect($req->get(qw(task_id auth_realm query path_info)));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2002 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
