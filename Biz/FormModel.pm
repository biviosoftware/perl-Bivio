# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FormModel;
use strict;
$Bivio::Biz::FormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FormModel - an abstract model of a user input screen

=head1 SYNOPSIS

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::FormModel::ISA = ('Bivio::Biz::Model');

=head1 DESCRIPTION

C<Bivio::Biz::FormModel> is the business logic behind HTML forms.  A FormModel
has fields like other models.  Fields are either I<visible> or
I<hidden>.  A FormModel may have a primary_key which is useful to know
how to load the form values from the database.

There are two modes the forms operate in: create and update.  update is
currently broken.  create is the mode where there is blank form which
has been filled in by the user.

If there is a form associated with the request, the individual fields are
validated and then the form-specific L<validate|"validate"> method is
called to do cross-field validation.

If the validation passes, i.e. no errors are put with
L<internal_put_error|"internal_put_error">, then either L<update|"update">
or L<create|"create"> is called depending on whether a database record
could be loaded with the information on the form or not.

Form field errors are always one of the enums in
L<Bivio::TypeError|Bivio::TypeError>.

The only tight connection to HTML is the way submit buttons are rendered.
The problem is that the value of a submit type field is the text that
appears in the button.  This means what the user sees is what we get
back.  The routines L<SUBMIT|"SUBMIT">, L<SUBMIT_OK|"SUBMIT_OK">, and
L<SUBMIT_CANCEL|"SUBMIT_CANCEL"> can be overridden by subclasses if
they would like different text to appear.

Free form input widgets (Text and TextArea) retrieve field values with
L<get_field_as_html|"get_field_as_html">, because the field may be in error and
the errant literal value may not be valid for the type.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUBMIT"></a>

=head2 SUBMIT : string

Returns name of submit button.

May be overriden.

=cut

sub SUBMIT {
    return 'submit';
}

=for html <a name="SUBMIT_CANCEL"></a>

=head2 SUBMIT_CANCEL : string

Returns Cancel button value

May be overriden.

=cut

sub SUBMIT_CANCEL {
    return 'Cancel';
}

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK : string

Returns OK button value.

May be overriden.

=cut

sub SUBMIT_OK {
    return '  OK  ';
}

#=IMPORTS
use Bivio::Agent::Task;
use Bivio::IO::Trace;
use Bivio::SQL::FormSupport;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::FormModel

Create a new FormModel associated with the request.

=cut

sub new {
    my($self) = &Bivio::Biz::Model::new(@_);
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->{$_PACKAGE} = {
	empty_properties => $self->internal_get,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request)

=head2 static execute(Bivio::Agent::Request, hash_ref values)

There are two modes:

=over 4

=item html form

I<values> is not passed.  Form values are processed from I<req.form>.
Loads a new instance of this model using the request.
If the form processing ends in errors, any transactions are rolled back.

=item action

This method is called as an action with I<values>.  I<values>
passed must match the properties of this FormModel.  If an error
occurs parsing the form, I<die> is called--internal program error
due to incorrect parameter passing.  On success, this method
returns normally.  This method should only be used if the caller
knows I<values> is valid.   L<validate|"validate"> is not called.

=back

=cut

sub execute {
    my($proto, $req, $values) = @_;
    my($self) = $proto->new($req);
    my($fields) = $self->{$_PACKAGE};

    # Called as an action internally, process values.  Do no validation.
    if ($values) {
	$self->internal_put($values);
	$self->execute_input();
	return _put_self($self) unless $fields->{errors};
	Carp::croak($self->as_string, ": called with invalid values");
    }

    my($input) = $req->unsafe_get('form');

    # User didn't input anything, render blank form
    unless ($input) {
	$self->execute_empty;
	return _put_self($self);
    }

    # User submitted a form, parse, validate, and execute
    # Cancel causes an immediate redirect.
    _parse($self, $input);
    unless ($fields->{errors}) {
	$self->validate();
	unless ($fields->{errors}) {
	    $self->execute_input();
	    unless ($fields->{errors}) {
		# Success, redirect to the next task.
		my($req) = $self->get_request;
		$req->client_redirect($req->get('task')->get('next'));
		# DOES NOT RETURN
	    }
	}
    }
    # Some type of error, rollback and put self so can render form again
    Bivio::Agent::Task->rollback;
    _put_self($self);
    return;
}

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Processes an empty form.  By default is a no-op.

=cut

sub execute_empty {
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Processes the form after validation.  By default is an no-op.

=cut

sub execute_input {
    return;
}

=for html <a name="get_errors"></a>

=head2 get_errors() : hash_ref

Returns the list of field errors.  C<undef> if no errors.

B<DO NOT MODIFY>.

=cut

sub get_errors {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{errors};
}

=for html <a name="get_field_as_html"></a>

=head2 get_field_as_html(string name) : string

Returns the field value as html.  If the field is in error and there
is no value, returns the literal value escaped for html.

Always returns a valid string, but may be undef.

=cut

sub get_field_as_html {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($value) = $self->unsafe_get($name);
    return $self->get_field_type($name)->to_html($value) if defined($value);
    return '' unless
	    $fields->{literals} && defined($fields->{literals}->{$name});
    return Bivio::Util::escape_html($fields->{literals}->{$name});
}

=for html <a name="get_field_error"></a>

=head2 get_field_error(string name) : Bivio::TypeError

Returns the error associated with a field.
Returns undef if field has no error associated with it.

=cut

sub get_field_error {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return undef unless $fields->{errors};
    return $fields->{errors}->{$name};
}

=for html <a name="get_hidden_field_values"></a>

=head2 get_hidden_field_values() : array_ref

Returns an array_ref of name, (literal) value pairs (even element is name,
odd element is value).

=cut

sub get_hidden_field_values {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($sql_support) = $self->internal_get_sql_support();
#TODO: make a constant
    my(@res);
    push(@res, 'version', $sql_support->get('version'));
    my($properties) = $self->internal_get();
    my($literals) = $fields->{literals};
    foreach my $col (@{$sql_support->get('hidden')}) {
	my($n) = $col->{name};
	my($v) = $col->{type}->to_literal($properties->{$n});
        $v = $literals && defined($literals->{$n}) ? $literals->{$n} : ''
		unless defined($v);
	push(@res, $col->{form_name}, $v);
    }
    return \@res;
}

=for html <a name="get_field_name_for_html"></a>

=head2 get_field_name_for_html(string name) : string

Get name for form appropriate to html.

=cut

sub get_field_name_for_html {
    return shift->internal_get_sql_support->get_column_name_for_html(@_);
}

=for html <a name="get_model_properties"></a>

=head2 get_model_properties(string model) : hash_ref

Returns the properties for this model that were passed in with the form.

=cut

sub get_model_properties {
    my($self, $model) = @_;
    my($sql_support) = $self->internal_get_sql_support();
    my($properties) = $self->internal_get();
    my($models) = $sql_support->get('models');
    Carp::croak($model, ': no such model') unless defined($models->{$model});
    my(%res);
    my($column_aliases) = $sql_support->get('column_aliases');
    foreach my $cn (@{$models->{$model}->{column_names_referenced}}) {
#TODO: Document this is being used elsewhere!
	my($pn) = $column_aliases->{$model.'.'.$cn}->{name};
	# Copy the property to the $cn if defined.
	$res{$cn} = $properties->{$pn}
		if defined($pn) && exists($properties->{$pn});
    }
    return \%res;
}

=for html <a name="in_error"></a>

=head2 in_error() : boolean

Returns true if any of the form fields are in error.

=cut

sub in_error {
    return defined(shift->{$_PACKAGE}->{errors});
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

Returns the L<Bivio::SQL::FormSupport|Bivio::SQL::FormSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    return Bivio::SQL::FormSupport->new(shift->internal_initialize);
}

=for html <a name="internal_put_error"></a>

=head2 internal_put_error(string property, Bivio::TypeError error)

=head2 internal_put_error(string property, Bivio::TypeError error, string literal)

Associate I<error> with I<property>.  If I<literal> in error is defined,
associate as well.

=cut

sub internal_put_error {
    my($self, $property, $error, $literal) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not a Bivio::TypeError')
		unless UNIVERSAL::isa($error, 'Bivio::TypeError');
    _trace($property, ': ', $error->as_string) if $_TRACE;
    $fields->{errors} = {} unless $fields->{errors};
    $fields->{errors}->{$property} = $error;
    if (defined($literal)) {
	$fields->{literals} = {} unless $fields->{literals};
	$fields->{literals}->{$property} = $literal;
    }
    return;
}

=for html <a name="load_from_model_properties"></a>

=head2 load_from_model_properties(string model)

Gets I<model> and copies all properties from I<model> to I<properties>.

=cut

sub load_from_model_properties {
    my($self, $model) = @_;
    my($sql_support) = $self->internal_get_sql_support();
    my($properties) = $self->internal_get();
    my($models) = $sql_support->get('models');
    Carp::croak($model, ': no such model') unless defined($models->{$model});
    my(%res);
    my($column_aliases) = $sql_support->get('column_aliases');
    my($m) = $self->get_model($model);
    foreach my $cn (@{$models->{$model}->{column_names_referenced}}) {
#TODO: Document this is being used elsewhere!
	my($pn) = $column_aliases->{$model.'.'.$cn}->{name};
	# Copy the model's property to this model
	$properties->{$pn} = $m->get($cn);
    }
    return;
}

=for html <a name="validate"></a>

=head2 validate()

By default this method does nothing. Subclasses should override it to provide
form specific validation.

=cut

sub validate {
    return;
}

#=PRIVATE METHODS

# _convert_values_to_form(Bivio::Biz::FormModel self, hash_ref values) : hash_ref
#
# Converts values to the form as if it came in from html.
# This is a bit inefficient, but at least we use the same logic.
#
sub _convert_values_to_form {
    my($self, $values) = @_;
#TODO: Should this be made more efficient, i.e. avoid convert roundtrip
    my($sql_support) = $self->internal_get_sql_support;
    my($columns) = $sql_support->get('columns');
    my($form) = {
	version => $sql_support->get('version'),
	submit => $self->SUBMIT_OK,
    };
    foreach my $k (keys(%$values)) {
	my($col) = $columns->{$k};
	Carp::croak("$k: unknown column") unless defined($col);
	$form->{$col->{form_name}} = $col->{type}->to_literal($values->{$k});
    }
    return;
}

# _put_self(Bivio::Biz::FormModel self)
#
# Sets itself in the request and returns.
#
sub _put_self {
    my($self) = @_;
    # Render form filled in from db, new form, or form with errors
    $self->get_request->put(ref($self) => $self, form_model => $self);
    return;
}

# _parse(Bivio::Biz::FormModel self, hash_ref form)
#
# Parses the form. If Cancel is encountered, redirects immediately.
#
sub _parse {
    my($self, $form) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Clear any incoming errors
    delete($fields->{errors});
    my($sql_support) = $self->internal_get_sql_support;
    _trace("form = ", $form) if $_TRACE;
    _parse_version($self, $form->{version}, $sql_support);
    _parse_submit($self, $form->{$self->SUBMIT});
    my($values) = {};
    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);
    return;
}

# _parse_col(Bivio::Biz::FormModel self, hash_ref form, Bivio::SQL::FormSupport sql_support, hash_ref values, boolean is_hidden)
#
# Parses the form field and returns the value.  Stores errors in the
# fields->{errors}.
#
#
sub _parse_cols {
    my($self, $form, $sql_support, $values, $is_hidden) = @_;
    my($fields) = $self->{$_PACKAGE};
    foreach my $col (@{$sql_support->get($is_hidden ? 'hidden' : 'visible')}) {
	my($fn) = $col->{form_name};
	my($v, $err) = $col->{type}->from_literal($form->{$fn});
	$values->{$col->{name}} = $v;
	next if defined($v);
	# Null field ok?
	unless ($err) {
	    next if $col->{constraint} == Bivio::SQL::Constraint::NONE();
	    $err = Bivio::TypeError::NULL();
	}
	# Error in field.  Save the original value.
	if ($is_hidden) {
	    $self->die(Bivio::DieCode::CORRUPT_FORM(),
		    {field => $col->{name}, actual => $form->{$fn},
			error => $err});
	}
	else {
	    $self->internal_put_error($col->{name}, $err, $form->{$fn});
	}
    }
    return;
}

# _parse_submit(Bivio::Biz::FormModel self, string value)
#
# Parses the submit button.  If there is an error, throws CORRUPT_FORM.
# If the button is Cancel, will redirect immediately.  If the button
# is "OK", just returns.
#
sub _parse_submit {
    my($self, $value) = @_;

    # default to OK, submit isn't passed when user presses 'enter'
    $value ||= $self->SUBMIT_OK;

    if ($value eq $self->SUBMIT_CANCEL) {
	my($req) = $self->get_request;
	# client redirect on cancel
	$req->client_redirect($req->get('task')->get('cancel'));
	# Does not return
    }
    return if $value eq $self->SUBMIT_OK;

#TODO: need a general fix for this
    # lynx trims submit padding!
    return if $self->SUBMIT_OK =~ /$value/x;

    $self->die(Bivio::DieCode::CORRUPT_FORM(),
	    {field => $self->SUBMIT(),
		expected => $self->SUBMIT_OK.' or '.$self->SUBMIT_CANCEL,
		actual => $value});
    return;
}

# _parse_version(Bivio::Biz::FormModel self, string value, Bivio::SQL::FormSupport sql_support)
#
# Parse the version number.  Throws VERSION_MISMATCH on error.
#
sub _parse_version {
    my($self, $value, $sql_support) = @_;
    if (defined($value)) {
	my($v) = Bivio::Type::Integer->from_literal($value);
	return if (defined($v) && $v eq $sql_support->get('version'));
    }
    $self->die(Bivio::DieCode::VERSION_MISMATCH(),
	    {field => 'version',
		expected => $sql_support->get('version'),
		actual => $value});
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
