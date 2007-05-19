# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ExpandableListFormModel;
use strict;
use Bivio::Base 'Bivio::Biz::ListFormModel';

# C<Bivio::Biz::ExpandableListFormModel> list form which can have extra rows

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub MUST_BE_SPECIFIED_FIELDS {
    # The list of fields that are expected to have NULL or UNSPECIFIED
    # L<Bivio::TypeError|Bivio::TypeError> on them if the row is to be considered ok
    # to be empty.  By default, this returns undef, in which case, this class
    # does nothing in L<validate_row|"validate_row">.
    #
    # When you supply an array_ref, this code will go through those fields.  If they
    # are I<all> NULL or UNSPECIFIED, then all those errors will be cleared.  You can
    # then check on of the 
    return;
}

sub ROW_INCREMENT {
    # number of empty rows to add to the list.
    return 4;
}

sub execute_empty {
    my($self) = @_;
    # Copies submitted values
    my($prev_self) = $self->get_request->unsafe_get(_key($self));
    $self->internal_put({%{$prev_self->internal_get}})
	if $prev_self;
    return shift->SUPER::execute_empty(@_);
}

sub execute_empty_row {
    my($self) = @_;
    # Loads visible list fields.
    foreach my $f (@{$self->get_info('visible_field_names')}) {
	$self->internal_load_field($f)
	    if $self->get_list_model->has_keys($f);
    }
    return;
}

sub internal_initialize {
    my($self) = @_;
    # B<FOR INTERNAL USE ONLY>
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

sub internal_initialize_list {
    my($self) = @_;
    # Appends empty rows to the list.
    my($fields) = $self->[$_IDI];
    my($list) = $self->SUPER::internal_initialize_list;
    return if $fields->{list_initialized};
    $fields->{list_initialized} = 1;
    my($req) = $self->get_request;
    my($form) = $req->get_form;
    my($prev_self) = $req->unsafe_get(_key($self));
    my($erc) = $prev_self ? $prev_self->get('empty_row_count')
	: $form ? $form->{$self->get_field_name_for_html('empty_row_count')}
	: $self->ROW_INCREMENT;
    $self->internal_put_field(empty_row_count => $erc);
    $form->{$self->get_field_name_for_html('empty_row_count')} = $erc
	if $form;
    $list->append_empty_rows($erc);
    return $list;
}

sub internal_load_field {
    my($self, $form_field, $list_field) = @_;
    # Loads I<form_field> from the list model's I<list_field> (defaults to
    # (I<form_field>) if this isn't a redirect through add_rows.
    return if $self->get_request->unsafe_get(_key($self));
    $list_field ||= $form_field;
    my($value) = $self->get_list_model->get($list_field);
    $self->internal_put_field($form_field, $value)
	if defined($value);
    return;
}

sub is_empty_row {
    my($self) = @_;
    # Returns true if the L<MUST_BE_SPECIFIED_FIELDS|"MUST_BE_SPECIFIED_FIELDS"> are
    # L<Bivio::Type::is_specified|Bivio::Type/"is_specified">.
    # Calls SUPER::is_empty_row if MUST_BE_SPECIFIED_FIELDS is false.
    foreach my $f (@{
	$self->MUST_BE_SPECIFIED_FIELDS
	    || return shift->SUPER::is_empty_row(@_),
    }) {
	return 0
	    if $self->get_field_type($f)->is_specified($self->unsafe_get($f));
    }
    return 1;
}

sub new {
    my($proto, @args) = @_;
    # Creates a new ExpandableListFormModel.
    my($self) = $proto->SUPER::new(@args);
    $self->[$_IDI] = {
	list_initialized => 0,
    };
    return $self;
}

sub validate {
    my($self, $form_button) = @_;
    # Responds to button click on 'add_rows', save the values on the
    # request and redirects to the same task.
    return shift->SUPER::validate(@_)
	unless $form_button eq 'add_rows';
    my($req) = $self->get_request;
    # increment the empty_row count and redirect to the same task
    $self->internal_put_field(empty_row_count =>
	$self->get('empty_row_count') + $self->ROW_INCREMENT);
    $req->put_durable(_key($self) => $self);
    # Put last for testing
    $req->server_redirect($req->get(qw(task_id auth_realm query path_info)));
    # DOES NOT RETURN
}

sub validate_row {
    my($self) = @_;
    # Clears errors on L<MUST_BE_SPECIFIED_FIELDS|"MUST_BE_SPECIFIED_FIELDS">
    # if L<is_empty_row|"is_empty_row">.
    return unless my $cols = $self->MUST_BE_SPECIFIED_FIELDS;
    return unless $self->is_empty_row;
    foreach my $f (@$cols) {
	$self->internal_clear_error($f);
    }
    return;
}

sub _key {
    my($self) = @_;
    # Returns the attribute key used on the request.
    return __PACKAGE__ . '.' . ref($self);
}

1;
