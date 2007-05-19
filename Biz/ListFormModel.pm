# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::ListFormModel;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::IO::Trace;

# C<Bivio::Biz::ListFormModel> is a form which can have repeated properties.
# The repeated properties are indexed with the primary key of an
# associated I<list_model> (see L<get_list_model|"get_list_model">).
# The primary key properties are identically named in the I<list_model>
# and the form model.
#
# Currently, we only implement a I<small> subset of C<ListModel>
# methods.  This is due to lack of time.
#
# The implementation is a subclass of FormModel and not ListModel, because more
# support is provided by FormModel.  We have had to copy a few methods from
# ListModel.  You can refer to any field in the FormModel by a name of the form
# I<field>.I<N> where I<N> is the row, starting at 0.  When you call
# L<next_row|"next_row"> the I<field>.I<row> is copied to I<field> where
# I<row> is
# the row you are on.  This makes life simpler when dealing with FormModel, which
# needs access to all values at one time and doesn't know about this module.  For
# example,
# L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">
# gets all the primary keys and stuffs them at the start of the form.  The list
# of hidden fields are returned by
# L<internal_get_hidden_field_names|"internal_get_hidden_field_names"> which is
# overriden by this module.
#
# To ensure consistency, there are a few sanity checks.  Also, we always drive
# the form processing using the list_model's I<next_row>.  If there is
# "too much" form data, it will be checked at the end of the iterations.
# If there is too little, it will blow up.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
# Separates row index from simple field name.  Must not be a regexp
# special and must be valid for a javascript field id.  Guess what?
# You can't change this value. ;-)
my($_SEP) = '_';

sub LAST_ROW {
    # Returns a constant which means the "last_row".
    return Bivio::Biz::ListModel->LAST_ROW;
}

sub do_rows {
    # Delegated to ListModel
    &_delegate;
}

sub do_rows_handler {
    # Delegated to ListModel
    &_delegate;
}

sub execute_empty {
    my($self) = @_;
    # Calls L<execute_empty_start|"execute_empty_start">,
    # L<execute_empty_row|"execute_empty_row"> for each
    # element in I<list_model>, and
    # L<execute_empty_end|"execute_empty_end">.
    #
    # On exit, the cursor will be reset.
    my($fields) = $self->[$_IDI];
    my($lm) = _execute_init($self);

    my($properties) = $self->internal_get;
    %$properties = (%$properties,
		    %{$self->get_fields_for_primary_keys($lm)});

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

sub execute_empty_end {
    # Subclasses should override if they need to perform an
    # operation during L<execute_empty|"execute_empty">
    # B<after> all rows have been processed.
    return;
}

sub execute_empty_row {
    my($self) = @_;
    # Subclasses should override if they need to perform an
    # operation during L<execute_empty|"execute_empty">
    # B<for each row>.
    #
    # By default, loads field data from model.
    $self->load_from_list_model_properties();
    return;
}

sub execute_empty_start {
    # Subclasses should override if they need to perform an
    # operation during L<execute_empty|"execute_empty">
    # B<before> all rows have been processed.
    return;
}

sub execute_ok {
    my($self, $button) = @_;
    # calls L<execute_ok_start|"execute_ok_start">,
    # L<execute_ok_row|"execute_ok_row"> and then
    # L<execute_ok_end|"execute_ok_end">.
    $self->reset_cursor;
    $self->execute_ok_start($button);
    while ($self->next_row) {
	$self->execute_ok_row($button);
    }
    my($result) = $self->execute_ok_end($button);
    $self->reset_cursor;
    return $result;
}

sub execute_ok_end {
    # Subclasses should override if they need to perform an
    # operation during L<execute_ok|"execute_ok">
    # B<after> all rows have been processed.
    return 0;
}

sub execute_ok_row {
    # Subclasses should override if they need to perform an
    # operation during L<execute_ok|"execute_ok">
    # B<for each row>.
    return;
}

sub execute_ok_start {
    # Subclasses should override if they need to perform an
    # operation during L<execute_ok|"execute_ok">
    # B<before> all rows have been processed.
    return;
}

sub format_uri {
    my($self) = shift;
    # Proxy to ListModel::format_uri, see there for details.
    return $self->get_list_model->format_uri(@_);
}

sub format_uri_for_sort {
    # Proxy to ListModel::format_uri_for_sort, see there for details.
    return shift->get_list_model->format_uri_for_sort(@_);
}

sub get_field_info {
    my($self, $name) = (shift, shift);
    # Returns I<attr> for I<field>.
    $name =~ s/$_SEP\d+$//o;
    return $self->SUPER::get_field_info($name, @_);
}

sub get_field_name_for_html {
    my($self, $name) = @_;
    # Returns the html name for this field with appropriate
    # row id.

    # Parse out the row number
    my($row);
    $name =~ s/$_SEP(\d+)$//o && ($row = $1);

    # Get the column info and return if not in_list
    my($col) = $self->get_field_info($name);
    unless ($col->{in_list}) {
	die($name, ': not in_list and row specified')
		if defined($row);
	return $col->{form_name};
    }

    # Row specified?
    unless (defined($row)) {
	my($fields) = $self->[$_IDI];
	die('no cursor') unless defined($fields->{cursor})
		&& $fields->{cursor} >= 0;
	$row = $fields->{cursor};
    }

    # Finally, return the row-qualified form field name
    return $col->{form_name}.$_SEP.$row;
}

sub get_field_name_in_list {
    my($n, $nr) = _names(@_);
    # Returns the indexed field name.  If this is not an "in_list" field, just
    # returns I<property>.  If no cursor, also returns I<property>.
    return defined($nr) ? $nr : $n;
}

sub get_fields_for_primary_keys {
    my($self) = @_;
    # Returns a hash_ref of the primary keys for the list class
    my($list) = $self->get_list_model || _execute_init($self);
    my($primary_key_names) = $list->get_info('primary_key_names');
    my(@list_keys) = ();
    my($row) = 0;
    $list->do_rows(sub {
        push(@list_keys,
	    map(($_.$_SEP.$row => $list->get($_)), @$primary_key_names),
	);
	$row++;
	return 1;
    });
    return {@list_keys};
}

sub get_list_class {
    my($self) = @_;
    # Returns the name of the list class.
    return $self->get_info('list_class');
}

sub get_list_model {
    # Returns the instance of the list model associated with this instance
    # of the list model.
    return shift->[$_IDI]->{list_model};
}

sub get_query {
    # Returns the
    # L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>
    # associated with the list model.
    return shift->get_list_model->get_query;
}

sub get_result_set_size {
    # Returns the result set size for I<list_model>.
    return shift->get_list_model->get_result_set_size;
}

sub has_fields {
    my($self) = shift;
    # Does the model have these fields?  This means does it have the
    # possibility of having these fields, not whether they are in the list.
    my(@args) = map {
	my($x) = $_;
	$x =~ s/$_SEP\d+$//o;
	$x;
    } @_;
    return $self->SUPER::has_fields(@args);
}

sub internal_clear_error {
    my($self, $property) = @_;
    # Clears the error on I<property> if any.
    foreach my $n (_names($self, $property)) {
	$self->SUPER::internal_clear_error($n)
	    if $n;
    }
    return;
}

sub internal_get_file_field_names {
    # B<Used internally to this module and FormModel.>
    return shift->[$_IDI]->{file_field_names};
}

sub internal_get_hidden_field_names {
    # B<Used internally to this module and FormModel.>
    #
    # Returns all the hidden fields for this instance of the form,
    # i.e. all list fields and the non-list fields.
    return shift->[$_IDI]->{hidden_field_names};
}

sub internal_get_visible_field_names {
    # B<Used internally to this module and FormModel.>
    #
    # Returns all the visible fields for this instance of the form,
    # i.e. all list fields and the non-list fields.
    return shift->[$_IDI]->{visible_field_names};
}

sub internal_initialize_list {
    my($self) = @_;
    # Finds and prepares the ListModel used for this form. Subclasses may
    # override this to provide custom list loading.
    my($lm) = $self->get_request->get($self->get_info('list_class'));
    $lm->reset_cursor;
    return $lm;
}

sub internal_pre_parse_columns {
    my($self) = @_;
    # B<Used internally to this module and FormModel.>
    #
    # Initializes the list model and what we expect for rows.
    # I<literals> is available.
    _execute_init($self);
    return;
}

sub internal_put_error {
    my($self, $property, $error) = @_;
    # See
    # L<Bivio::Biz::FormModel::internal_put_error|Bivio::Biz::FormModel/"internal_put_error">.
    my($n, $nr) = _names($self, $property);
    $self->SUPER::internal_put_error($n, $error) if $n;
    $self->SUPER::internal_put_error($nr, $error) if $nr;
    return;
}

sub internal_put_field {
    my($self, $property, $value) = @_;
    # Puts a value on a field.  No validation checking.
    my($n, $nr) = _names($self, $property);
    my($properties) = $self->internal_get;
    $properties->{$n} = $value if $n;
    $properties->{$nr} = $value if $nr;
    return;
}

sub is_empty_row {
    # Calls get_list_model.is_empty_row.
    return shift->get_list_model->is_empty_row;
}

sub load_from_list_model_properties {
    my($self, $model) = @_;
    # Load form values from model.
    $model ||= $self->get_list_model();
    foreach my $field (@{$self->get_info('visible_field_names')}) {
	$self->internal_put_field($field, $model->get($field))
	    if $model->has_keys($field);
    }
    return;
}

sub map_rows {
    # Delegated to ListModel
    &_delegate;
}

sub new {
    my($self) = Bivio::Biz::FormModel::new(@_);
    # Creates a new ListFormModel.
    $self->[$_IDI] = {};
    return $self;
}

sub next_row {
    my($self) = @_;
    # Advances to the next row in the list.  Also advances I<list_model>.
    # The form properties which are
    # not I<in_list> are always available.  I<in_list> properties are
    # available as non-qualified names, i.e. sans row number suffix,
    # for the current row only.  All I<in_list> properties are always
    # available in row-qualified form, i.e. I<name>.I<row>.
    my($fields) = $self->[$_IDI];
    $self->die('no cursor')
	unless defined($fields->{cursor});
    $self->internal_clear_model_cache;
    my($lm) = $fields->{list_model};
    # Advance only if list_model can advance
    unless ($lm->next_row) {
	$fields->{cursor} = undef;
	_clear_row($self);
	return 0;
    }
    return _set_row($self, ++$fields->{cursor})
}

sub reset_cursor {
    my($self) = @_;
    # Places the cursor at the start of the list.  Also resets cursor
    # of I<list_model>.
    my($fields) = $self->[$_IDI];
    $fields->{list_model}->reset_cursor;
    $fields->{cursor} = -1;
    $self->internal_clear_model_cache;
    _clear_row($self);
    return;
}

sub set_cursor {
    my($self) = shift;
    my($fields) = $self->[$_IDI];
    $self->internal_clear_model_cache;
    my($lm) = $self->get_list_model;
    $lm->set_cursor(@_);
    return _set_row($self, $fields->{cursor} = $lm->get_cursor);
}

sub set_cursor_or_die {
    my($self) = shift;
    # Calls L<set_cursor|"set_cursor"> and dies with DIE
    # if it returns false.
    #
    # Returns self.
    $self->throw_die('DIE', {message => 'no such row', entity => $_[0]})
	unless $self->set_cursor(@_);
    return $self;
}

sub validate {
    my($self) = @_;
    # Calls L<validate_start|"validate_start">,
    # L<validate_row|"validate_row"> for each
    # element in I<list_model>, and
    # L<validate_end|"validate_end">.
    my($fields) = $self->[$_IDI];
    my($lm) = $self->get_list_model;

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

sub validate_end {
    # Subclasses should override if they need to do validation B<after>
    # all rows are validated.
    return;
}

sub validate_row {
    # Subclasses should override if they need to do validation
    # B<for each row>.
    return;
}

sub validate_start {
    # Subclasses should override if they need to do validation B<before>
    # all rows are validated.
    return;
}

sub _clear_row {
    my($self) = @_;
    # Clear the row, i.e. make it so literals and values do not contain
    # in_list values which are not qualified by a row number.
    my($literals) = $self->internal_get_literals;
    my($values) = $self->internal_get;
    foreach my $f (@{$self->get_info('in_list')}) {
	my($n, $fn) = @{$f}{'name', 'form_name'};
	delete($values->{$n});
	delete($literals->{$fn})
	    if defined($fn);
	$self->SUPER::internal_clear_error($n);
    }
    return;
}

sub _collision {
    my($self, $msg, $row) = @_;
    # Blows up with UPDATE_COLLISION.
    $self->throw_die('UPDATE_COLLISION', {
	message => $msg.' row #'.$row.' in ListFormModel',
	list_model => ref($self->get_list_model),
	list_attrs => $self->get_list_model->internal_get,
    });
    return;
}

sub _delegate {
    # Delegate the caller function to ListModel
    return &{\&{join('::',
        'Bivio::Biz::ListModel',
	(caller(1))[3] =~ /.*::(.*)$/,
    )}};
}

sub _execute_init {
    my($self) = @_;
    # Finds the list model by looking up list_class in the request.
    # Initializes rows and cursor.
    my($req) = $self->get_request;

    # Get the the list_class instance
    my($lm) = $self->internal_initialize_list();
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
    $self->[$_IDI] = {
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

sub _names {
    my($self, $name) = @_;
    # Returns the unqualified and qualified names.  Uses cursor to
    # know whether we are on the row specified by property (if specified).

    # If there is no property name, global error
    return ($self->GLOBAL_ERROR_FIELD, undef)
	unless $name;

    my($sql_support) = $self->internal_get_sql_support;

    # Parse out the row number
    my($row);
    $name =~ s/$_SEP(\d+)$//o && ($row = $1);

    # Get the column info and return if not in_list
    my($col) = $sql_support->get_column_info($name);
    unless ($col->{in_list}) {
	die($name, ': not in_list and row specified')
	    if defined($row);
	# No qualified name
	return ($name, undef);
    }

    # Row specified?
    my($fields) = $self->[$_IDI];
    if (defined($row)) {
	if (defined($fields->{cursor}) && $fields->{cursor} >= 0) {
	    # If there is a cursor and it matches the row, then
	    # return unqualified and qualified names.
	    return ($name, $name.$_SEP.$row)
		if $fields->{cursor} == $row;
	}
	# No unqualified name
	return (undef, $name.$_SEP.$row);
    }

    # No row specified, must be a cursor and must return both forms
    die('no cursor') unless defined($fields->{cursor})
	&& $fields->{cursor} >= 0;
    return ($name, $name.$_SEP.$fields->{cursor});
}

sub _set_row {
    my($self, $cursor) = @_;
    # Go to next row, so copy properties, literals and errors to simple names
    my($literals) = $self->internal_get_literals;
    my($values) = $self->internal_get;
    my($errors) = $self->get_errors;
    foreach my $f (@{$self->get_info('in_list')}) {
	my($n, $fn) = @{$f}{'name', 'form_name'};
	my($nr) = $n.$_SEP.$cursor;
	$values->{$n} = $values->{$nr};
	# No literals for "other" entries
	$literals->{$fn} = $literals->{"$fn$_SEP$cursor"}
	    if defined($fn);
	$errors->{$n} = $errors->{$nr}
	    if $errors;
    }
    return 1;
}

1;
