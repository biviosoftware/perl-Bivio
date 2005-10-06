# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
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

=for html <a name="MUST_BE_SPECIFIED_FIELDS"></a>

=head2 MUST_BE_SPECIFIED_FIELDS : array_ref

The list of fields that are expected to have NULL or UNSPECIFIED
L<Bivio::TypeError|Bivio::TypeError> on them if the row is to be considered ok
to be empty.  By default, this returns undef, in which case, this class
does nothing in L<validate_row|"validate_row">.

When you supply an array_ref, this code will go through those fields.  If they
are I<all> NULL or UNSPECIFIED, then all those errors will be cleared.  You can
then check on of the 

=cut

sub MUST_BE_SPECIFIED_FIELDS {
    return;
}

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

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Copies submitted values

=cut

sub execute_empty {
    my($self) = @_;
    my($prev_self) = $self->get_request->unsafe_get(_key($self));
    $self->internal_put({%{$prev_self->internal_get}})
	if $prev_self;
    return shift->SUPER::execute_empty(@_);
}

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Loads visible list fields.

=cut

sub execute_empty_row {
    my($self) = @_;
    foreach my $f (@{$self->get_info('visible_field_names')}) {
	$self->internal_load_field($f)
	    if $self->get_list_model->has_keys($f);
    }
    return;
}

=for html <a name="internal_load_field"></a>

=head2 internal_load_field(string form_field, string list_field)

Loads I<form_field> from the list model's I<list_field> (defaults to
(I<form_field>) if this isn't a redirect through add_rows.

=cut

sub internal_load_field {
    my($self, $form_field, $list_field) = @_;
    return if $self->get_request->unsafe_get(_key($self));
    $list_field ||= $form_field;
    my($value) = $self->get_list_model->get($list_field);
    $self->internal_put_field($form_field, $value)
	if defined($value);
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
    my($list) = $self->SUPER::internal_initialize_list;
    return if $fields->{list_initialized};
    $fields->{list_initialized} = 1;
    my($req) = $self->get_request;
    my($form) = $req->get('form');
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

=for html <a name="is_empty_row"></a>

=head2 is_empty_row() : boolean

Returns true if the L<MUST_BE_SPECIFIED_FIELDS|"MUST_BE_SPECIFIED_FIELDS"> are
L<Bivio::Type::is_specified|Bivio::Type/"is_specified">.
Calls SUPER::is_empty_row if MUST_BE_SPECIFIED_FIELDS is false.

=cut

sub is_empty_row {
    my($self) = @_;
    foreach my $f (@{
	$self->MUST_BE_SPECIFIED_FIELDS
	    || return shift->SUPER::is_empty_row(@_),
    }) {
	return 0
	    if $self->get_field_type($f)->is_specified($self->unsafe_get($f));
    }
    return 1;
}

=for html <a name="validate"></a>

=head2 validate(string form_button)

Responds to button click on 'add_rows', save the values on the
request and redirects to the same task.

=cut

sub validate {
    my($self, $form_button) = @_;
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

=for html <a name="validate_row"></a>

=head2 validate_row()

Clears errors on L<MUST_BE_SPECIFIED_FIELDS|"MUST_BE_SPECIFIED_FIELDS">
if L<is_empty_row|"is_empty_row">.

=cut

sub validate_row {
    my($self) = @_;
    return unless my $cols = $self->MUST_BE_SPECIFIED_FIELDS;
    return unless $self->is_empty_row;
    foreach my $f (@$cols) {
	$self->internal_clear_error($f);
    }
    return;
}

#=PRIVATE METHODS

# _key(self) : string
#
# Returns the attribute key used on the request.
#
sub _key {
    my($self) = @_;
    return __PACKAGE__ . '.' . ref($self);
}

=head1 COPYRIGHT

Copyright (c) 1999-2004 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
