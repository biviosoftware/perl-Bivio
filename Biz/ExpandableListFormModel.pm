# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ExpandableListFormModel;
use strict;
$Bivio::Biz::ExpandableListFormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::ExpandableListFormModel::VERSION;

=head1 NAME

Bivio::Biz::ExpandableListFormModel - list form which can have extra rows

=head1 SYNOPSIS

    use Bivio::Biz::ExpandableListFormModel;
    Bivio::Biz::ExpandableListFormModel->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::Biz::ExpandableListFormModel::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::ExpandableListFormModel> list form which can have extra rows

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_ROW_INCREMENT) = 4;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ExpandableListFormModel

Creates a new ExpandableListFormModel.


=cut

sub new {
    my($proto, @args) = @_;
    my($self) = $proto->SUPER::new(@args);
    $self->{$_PACKAGE} = {
	list_initialized => 0,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="internal_load_field"></a>

=head2 internal_load_field(string field) : string

Loads the specified field from the list model, or from the request
values depending on whether the task was redirected through add_rows.

=cut

sub internal_load_field {
    my($self, $field) = @_;
    my($list) = $self->get_list_model;
    my($rows) = $self->get_request->unsafe_get($_PACKAGE.'rows');

    my($value) = defined($rows)
	    ? $rows->[$list->get_cursor]->{$field}
	    : $list->get($field);
    $self->internal_put_field($field, $value) if $value;
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
		type => 'Amount',
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
    my($fields) = $self->{$_PACKAGE};
    my($list) = $self->SUPER::internal_initialize_list();
    return if $fields->{list_initialized};
    $fields->{list_initialized} = 1;
    my($req) = $self->get_request;
    my($form) = $req->get('form');
    my($empty_row_count) = $req->unsafe_get($_PACKAGE.'empty_row_count');
    unless ($empty_row_count) {
	if ($form) {
	    $empty_row_count = $form->{
		$self->get_field_name_for_html('empty_row_count')};
	}
	else {
	    # default number of rows to add
	    $empty_row_count = $_ROW_INCREMENT;
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
    my($self) = @_;

    if (defined($self->get('add_rows'))) {
	# increment the empty_row count and redirect to the same task
	my($req) = $self->get_request;
	$req->put($_PACKAGE.'empty_row_count' =>
		$self->get('empty_row_count') + $_ROW_INCREMENT);

	my($rows) = [];
	$self->reset_cursor;
	while ($self->next_row) {
	    # make a copy of the current values
	    push(@$rows, {%{$self->internal_get}});
	}
	$self->reset_cursor;
	$req->put($_PACKAGE.'rows' => $rows);
	$req->server_redirect($req->get('task_id'));
    }
    $self->SUPER::validate();
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
