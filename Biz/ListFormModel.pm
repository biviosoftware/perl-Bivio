# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ListFormModel;
use strict;
$Bivio::Biz::ListFormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListFormModel - a form with repeated properties

=head1 SYNOPSIS

    use Bivio::Biz::ListFormModel;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::ListFormModel::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::ListFormModel> is a form which can have repeated properties.
The repeated properties are indexed with the primary key of an
associated I<list_model> (see L<get_list_model|"get_list_model">).
The primary key properties are identically named in the I<list_model>
and the form model.

Currently, we only implement a I<small> subset of C<ListModel>
methods.  This is due to lack of time.

The implementation is a subclass of FormModel and not ListModel, because more
support is provided by FormModel.  We have had to copy a few methods from
ListModel.  You can refer to any field in the FormModel by a name of the form
I<field>.I<N> where I<N> is the row, starting at 0.  When you call
L<next_row|"next_row"> the I<field>.I<row> is copied to I<field> where
I<row> is
the row you are on.  This makes life simpler when dealing with FormModel, which
needs access to all values at one time and doesn't know about this module.  For
example,
L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">
gets all the primary keys and stuffs them at the start of the form.  The list
of hidden fields are returned by
L<internal_get_hidden_field_names|"internal_get_hidden_field_names"> which is
overriden by this module.

To ensure consistency, there are a few sanity checks.  Also, we always drive
the form processing using the list_model's I<next_row>.  If there is
"too much" form data, it will be checked at the end of the iterations.
If there is too little, it will blow up.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# Separates row index from simple field name.  Must not be a regexp
# special and must be valid for a javascript field id.  Guess what?
# You can't change this value. ;-)
my($_SEP) = '_';

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Calls L<execute_empty_start|"execute_empty_start">,
L<execute_empty_row|"execute_empty_row"> for each
element in I<list_model>, and
L<execute_empty_end|"execute_empty_end">.

On exit, the cursor will be reset.

=cut

sub execute_empty {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($lm) = _execute_init($self);

    # For each row, we have to copy primary_key values
    my($primary_key_names) = $lm->get_info('primary_key_names');
    my($properties) = $self->internal_get;
    foreach (my($row) = 0; $lm->next_row; $row++) {
	foreach my $pkn (@$primary_key_names) {
	    $properties->{$pkn.$_SEP.$row} = $lm->get($pkn);
	}
    }

#TODO: Optimize.  Don't make calls if method doesn't exist
    # Do start/row/end
    $self->reset_cursor;
    $self->execute_empty_start;
    while ($self->next_row) {
	$self->execute_empty_row;
    }
    $self->execute_empty_end;
    $self->reset_cursor;
    return;
}

=for html <a name="execute_empty_end"></a>

=head2 execute_empty_end()

Subclasses should override if they need to perform an
operation during L<execute_empty|"execute_empty">
B<after> all rows have been processed.

=cut

sub execute_empty_end {
    return;
}

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Subclasses should override if they need to perform an
operation during L<execute_empty|"execute_empty">
B<for each row>.

=cut

sub execute_empty_row {
    return;
}

=for html <a name="execute_empty_start"></a>

=head2 execute_empty_start()

Subclasses should override if they need to perform an
operation during L<execute_empty|"execute_empty">
B<before> all rows have been processed.

=cut

sub execute_empty_start {
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()


=cut

sub execute_input {
    my($self) = @_;

#TODO: Optimize.  Don't make calls if method doesn't exist
    # Do start/row/end
    $self->reset_cursor;
    $self->execute_input_start;
    while ($self->next_row) {
	$self->execute_input_row;
    }
    $self->execute_input_end;
    $self->reset_cursor;
    return;
}

=for html <a name="execute_input_end"></a>

=head2 execute_input_end()

Subclasses should override if they need to perform an
operation during L<execute_input|"execute_input">
B<after> all rows have been processed.

=cut

sub execute_input_end {
    return;
}

=for html <a name="execute_input_row"></a>

=head2 execute_input_row()

Subclasses should override if they need to perform an
operation during L<execute_input|"execute_input">
B<for each row>.

=cut

sub execute_input_row {
    return;
}

=for html <a name="execute_input_start"></a>

=head2 execute_input_start()

Subclasses should override if they need to perform an
operation during L<execute_input|"execute_input">
B<before> all rows have been processed.

=cut

sub execute_input_start {
    return;
}

=for html <a name="format_uri"></a>

=head2 format_uri() : 

Proxy to ListModel::format_uri, see there for details.

=cut

sub format_uri {
    my($self) = shift;
    return $self->get_list_model->format_uri(@_);
}

=for html <a name="get_field_info"></a>

=head2 get_field_info(string field, string attr) : any

Returns I<attr> for I<field>.

=cut

sub get_field_info {
    my($self, $name) = (shift, shift);
    $name =~ s/$_SEP\d+$//o;
    return $self->SUPER::get_field_info($name, @_);
}

=for html <a name="get_field_name_for_html"></a>

=head2 get_field_name_for_html(string name) : string

Returns the html name for this field with appropriate
row id.

=cut

sub get_field_name_for_html {
    my($self, $name) = @_;

    # Parse out the row number
    my($row);
    $name =~ s/$_SEP(\d+)$//o && ($row = $1);

    # Get the column info and return if not in_list
    my($col) = $self->get_field_info($name);
    unless ($col->{in_list}) {
	Carp::croak($name, ': not in_list and row specified')
		if defined($row);
	return $col->{form_name};
    }

    # Row specified?
    unless (defined($row)) {
	my($fields) = $self->{$_PACKAGE};
	Carp::croak('no cursor') unless defined($fields->{cursor})
		&& $fields->{cursor} >= 0;
	$row = $fields->{cursor};
    }

    # Finally, return the row-qualified form field name
    return $col->{form_name}.$_SEP.$row;
}

=for html <a name="get_list_model"></a>

=head2 get_list_model() : Bivio::Biz::ListModel

Returns the instance of the list model associated with this instance
of the list model.

=cut

sub get_list_model {
    return shift->{$_PACKAGE}->{list_model};
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the result set size for I<list_model>.

=cut

sub get_result_set_size {
    return shift->get_list_model->get_result_set_size;
}

=for html <a name="has_fields"></a>

=head2 has_fields(string name, ...) : boolean

Does the model have these fields?  This means does it have the
possibility of having these fields, not whether they are in the list.

=cut

sub has_fields {
    my($self) = shift;
    my(@args) = map {
	my($x) = $_;
	$x =~ s/$_SEP\d+$//o;
	$x;
    } @_;
    return $self->SUPER::has_fields(@args);
}

=for html <a name="internal_clear_error"></a>

=head2 internal_clear_error(string property)

Clears the error on I<property> if any.

=cut

sub internal_clear_error {
    my($self, $property, $error, $literal) = @_;

    my($n, $nr) = _names($self, $property);
    $self->SUPER::internal_clear_error($n) if $n;
    $self->SUPER::internal_clear_error($nr) if $nr;
    return;
}

=for html <a name="internal_get_file_field_names"></a>

=head2 internal_get_file_field_names() : array_ref

B<Used internally to this module and FormModel.>

=cut

sub internal_get_file_field_names {
    return shift->{$_PACKAGE}->{file_field_names};
}

=for html <a name="internal_get_hidden_field_names"></a>

=head2 internal_get_hidden_field_names() : array_ref

B<Used internally to this module and FormModel.>

Returns all the hidden fields for this instance of the form,
i.e. all list fields and the non-list fields.

=cut

sub internal_get_hidden_field_names {
    return shift->{$_PACKAGE}->{hidden_field_names};
}

=for html <a name="internal_get_visible_field_names"></a>

=head2 internal_get_visible_field_names() : array_ref

B<Used internally to this module and FormModel.>

Returns all the visible fields for this instance of the form,
i.e. all list fields and the non-list fields.

=cut

sub internal_get_visible_field_names {
    return shift->{$_PACKAGE}->{visible_field_names};
}

=for html <a name="internal_initialize_list"></a>

=head2 internal_initialize_list(Bivio::Biz::Model::ListModel list)

Called prior to doing any list manipulations. Allows subclasses to do
any extra list changes.

=cut

sub internal_initialize_list {
    return;
}

=for html <a name="internal_pre_parse_columns"></a>

=head2 internal_pre_parse_columns()

B<Used internally to this module and FormModel.>

Initializes the list model and what we expect for rows.
I<literals> is available.

=cut

sub internal_pre_parse_columns {
    my($self) = @_;
    _execute_init($self);
    return;
}

=for html <a name="internal_put_error"></a>

=head2 internal_put_error(string property, any error)

See
L<Bivio::Biz::FormModel::internal_put_error|Bivio::Biz::FormModel/"internal_put_error">.

=cut

sub internal_put_error {
    my($self, $property, $error) = @_;
    my($n, $nr) = _names($self, $property);
    $self->SUPER::internal_put_error($n, $error) if $n;
    $self->SUPER::internal_put_error($nr, $error) if $nr;
    return;
}

=for html <a name="internal_put_field"></a>

=head2 internal_put_field(string property, any value)

Puts a value on a field.  No validation checking.

=cut

sub internal_put_field {
    my($self, $property, $value) = @_;
    my($n, $nr) = _names($self, $property);
    my($properties) = $self->internal_get;
    $properties->{$n} = $value if $n;
    $properties->{$nr} = $value if $nr;
    return;
}

=for html <a name="next_row"></a>

=head2 next_row() : boolean

Advances to the next row in the list.  Also advances I<list_model>.
The form properties which are
not I<in_list> are always available.  I<in_list> properties are
available as non-qualified names, i.e. sans row number suffix,
for the current row only.  All I<in_list> properties are always
available in row-qualified form, i.e. I<name>.I<row>.

=cut

sub next_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    Carp::croak('no cursor') unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    my($lm) = $fields->{list_model};
    # Advance only if list_model can advance
    unless ($lm->next_row) {
	# No place to advance to
	$fields->{cursor} = undef;
	_clear_row($self);
	return 0;
    }
    my($row) = ++$fields->{cursor};

    # Go to next row, so copy properties, literals and errors to simple names
    my($literals) = $self->internal_get_literals;
    my($values) = $self->internal_get;
    my($errors) = $self->get_errors;
    foreach my $f (@{$self->get_info('in_list')}) {
	my($n, $fn) = @{$f}{'name', 'form_name'};
	my($nr) = $n.$_SEP.$row;
	$values->{$n} = $values->{$nr};
	# No literals for "other" entries
	$literals->{$fn} = $literals->{$fn.$_SEP.$row} if defined($fn);
	$errors->{$n} = $errors->{$nr} if $errors;
    }
    return 1;
}

=for html <a name="reset_cursor"></a>

=head2 reset_cursor()

Places the cursor at the start of the list.  Also resets cursor
of I<list_model>.

=cut

sub reset_cursor {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{list_model}->reset_cursor;
    $fields->{cursor} = -1;
    $self->internal_clear_model_cache;
    _clear_row($self);
    return;
}

=for html <a name="validate"></a>

=head2 validate()

Calls L<validate_start|"validate_start">,
L<validate_row|"validate_row"> for each
element in I<list_model>, and
L<validate_end|"validate_end">.

=cut

sub validate {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($lm) = _execute_init($self);

    # For each row, validate primary_key values are match list_model's exactly
    my($primary_key) = $lm->get_info('primary_key');
    my($properties) = $self->internal_get;
    my($row);
    foreach ($row = 0; $lm->next_row; $row++) {
	foreach my $pk (@$primary_key) {
	    my($n) = $pk->{name};
	    my($nr) = $n.$_SEP.$row;
	    _collision($self, 'missing', $row)
		    unless defined($properties->{$nr});
#TODO: Should this be "is_equal"?  This is probably "good enough".
#      It will slow it down a lot to make a method call for each
#      row/attribute.  "eq" works in all cases and probably in future.
	    _collision($self, 'mismatch', $row)
		    unless $properties->{$nr} eq $lm->get($n);
	}
    }

    # No more rows should exist
    foreach my $pk (@$primary_key) {
	_collision($self, 'extra', $row)
		if exists($properties->{$pk->{name}.$_SEP.$row});
    }

#TODO: Optimize.  Don't make calls if method doesn't exist
    # Do start/row/end
    $self->reset_cursor;
    $self->validate_start;
    while ($self->next_row) {
	$self->validate_row;
    }
    $self->validate_end;
    $self->reset_cursor;
    return;
}

=for html <a name="validate_end"></a>

=head2 validate_end()

Subclasses should override if they need to do validation B<after>
all rows are validated.

=cut

sub validate_end {
    return;
}

=for html <a name="validate_row"></a>

=head2 validate_row()

Subclasses should override if they need to do validation
B<for each row>.

=cut

sub validate_row {
    return;
}

=for html <a name="validate_start"></a>

=head2 validate_start()

Subclasses should override if they need to do validation B<before>
all rows are validated.

=cut

sub validate_start {
    return;
}

#=PRIVATE METHODS

# _clear_row(Bivio::Biz::ListFormModel self)
#
# Clear the row, i.e. make it so literals and values do not contain
# in_list values which are not qualified by a row number.
#
sub _clear_row {
    my($self) = @_;
    my($literals) = $self->internal_get_literals;
    my($values) = $self->internal_get;
    my($errors) = $self->get_errors;
    foreach my $f (@{$self->get_info('in_list')}) {
	my($n, $fn) = @{$f}{'name', 'form_name'};
	delete($values->{$n});
	# Other fields don't have form names
	delete($literals->{$fn}) if defined($fn);
	delete($errors->{$n}) if $errors;
    }
    return;
}

# _collision(Bivio::Biz::ListFormModel self, string msg, int row)
#
# Blows up with UPDATE_COLLISION.
#
sub _collision {
    my($self, $msg, $row) = @_;
    $self->die('UPDATE_COLLISION', {
	message => $msg.' row #'.$row.' in ListFormModel',
	list_model => ref($self->get_list_model),
	list_attrs => $self->get_list_model->internal_get,
    });
    return;
}

# _execute_init(Bivio::Biz::ListFormModel self) : Bivio::Biz::ListModel
#
# Finds the list model by looking up list_class in the request.
# Initializes rows and cursor.
#
sub _execute_init {
    my($self) = @_;
    my($req) = $self->get_request;

    # Get the the list_class instance
    my($lm) = $req->get($self->get_info('list_class'));
    $lm->reset_cursor;
    $self->internal_initialize_list($lm);

    # Get the field names based on list instance
    my($sql_support) = $self->internal_get_sql_support();

    # Do not use in_list columns attribute, because it contains "other"
    # columns as well.
    my($visible_cols, $hidden_cols) = $sql_support->get('visible', 'hidden');
    my($visible, $hidden) = ([], []);

    my(@file_fields);
#TODO: Cache this
    # Initialize not in_list visible/hidden names
    my(@in_list);
    foreach my $c (@$visible_cols, @$hidden_cols) {
	if ($c->{in_list}) {
	    push(@in_list, $c);
	    next;
	}
	push(@{$c->{is_visible} ? $visible : $hidden}, $c->{name});
	push(@file_fields, $c->{name}) if $c->{is_file_field};
    }

    # Initialize in_list visible and hidden names
    for (my($row) = $lm->get_result_set_size - 1; $row >= 0; $row--) {
	foreach my $c (@in_list) {
	    my($nr) = $c->{name}.$_SEP.$row;
	    push(@{$c->{is_visible} ? $visible : $hidden}, $nr);
	    push(@file_fields, $nr) if $c->{is_file_field};
	}
    }

    # Re-initialize fields
    $self->{$_PACKAGE} = {
	cursor => -1,
	list_model => $lm,
	visible_field_names => $visible,
	hidden_field_names => $hidden,
	file_field_names => @file_fields ? \@file_fields : undef,
    };
    if ($_TRACE) {
	_trace('hidden: ', $hidden);
	_trace('visible: ', $visible);
	_trace('file_fields: ', \@file_fields);
    }
    return $lm;
}

# _names(Bivio::Biz::ListFormModel self, string name) : array
#
# Returns the unqualified and qualified names.  Uses cursor to
# know whether we are on the row specified by property (if specified).
#
sub _names {
    my($self, $name) = @_;

    # If there is no property name, global error
    return ($_SEP, undef) unless $name;

    my($sql_support) = $self->internal_get_sql_support;

    # Parse out the row number
    my($row);
    $name =~ s/$_SEP(\d+)$//o && ($row = $1);

    # Get the column info and return if not in_list
    my($col) = $sql_support->get_column_info($name);
    unless ($col->{in_list}) {
	Carp::croak($name, ': not in_list and row specified')
		if defined($row);
	# No qualified name
	return ($name, undef);
    }

    # Row specified?
    my($fields) = $self->{$_PACKAGE};
    if (defined($row)) {
	if (defined($fields->{cursor}) && $fields->{cursor} >= 0) {
	    # If there is a cursor and it matches the row, then
	    # return unqualified and qualified names.
	    return ($name, $name.$_SEP.$row) if $fields->{cursor} == $row;
	}

	# No unqualified name
	return (undef, $name.$_SEP.$row);
    }

    # No row specified, must be a cursor and must return both forms
    Carp::croak('no cursor') unless defined($fields->{cursor})
	    && $fields->{cursor} >= 0;
    return ($name, $name.$_SEP.$fields->{cursor});
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
