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

If there is a form associated with the request, the individual fields are
validated and then the form-specific L<validate|"validate"> method is
called to do cross-field validation.

If the validation passes, i.e. no errors are put with
L<internal_put_error|"internal_put_error">, then
L<execute_input|"execute_input"> is called.

A form may have a context.  This is specified by the C<require_context>
in
L<internal_initialize_sql_support|"internal_initialize_sql_support">.
The context is how we got to this form, e.g. from another form and
the contents of that form.  Forms with context return to the uri
specified in the context on "ok" completion.

A query may have a context as well.  The form's context overrides
the query's context.  The query's context is usually only valid
for empty forms.

If the context contains a form, it may be manipulated with
L<unsafe_get_context_field|"unsafe_get_context_field"> and
L<put_context_fields|"put_context_fields">.
For example, a symbol lookup form might set the symbol selected
in the form which requested the lookup.

If a form is executed as a the result of a server redirect
and L<SUBMIT_UNWIND|"SUBMIT_UNWIND"> is set,
no data transforms will occur and the form will render literally
as it was entered before.  User gets a new opportunity to OK or
CANCEL.

The only tight connection to HTML is the way submit buttons are rendered.
The problem is that the value of a submit type field is the text that
appears in the button.  This means what the user sees is what we get
back.  The routines L<SUBMIT|"SUBMIT">, L<SUBMIT_OK|"SUBMIT_OK">, and
L<SUBMIT_CANCEL|"SUBMIT_CANCEL"> can be overridden by subclasses if
they would like different text to appear.

A form may specialize its L<is_submit_ok|"is_submit_ok"> method.
This allows, for example, the form to have multiple "ok" buttons.

Form field errors are always one of the enums in
L<Bivio::TypeError|Bivio::TypeError>.

Free text input widgets (Text and TextArea) retrieve field values with
L<get_field_as_html|"get_field_as_html">, because the field may be in error
and the errant literal value may not be valid for the type.

=cut

=head1 CONSTANTS

=cut

=for html <a name="MAX_FIELD_SIZE"></a>

=head2 MAX_FIELD_SIZE : int

To avoid tossing around huge chunks of invalid data, we have an maximum
size of a field for non-FileField values.

I<Subclasses may override this method and should if they expect
huge fields, e.g. mail message bodies.>

=cut

sub MAX_FIELD_SIZE {
    return 0x10000;
}

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

=for html <a name="SUBMIT_UNWIND"></a>

=head2 SUBMIT_UNWIND : string

Returns the internal tag string for continuation of a form
which was redirected initially to another form.

B<DO NOT USE THIS VALUE FOR SUBMIT LABELS.>

If you want to treate C<SUBMIT_UNWIND> as
L<SUBMIT_OK|"SUBMIT_OK">, override in subclass
and return C<SUBMIT_OK>'s value.  This method always checks
C<SUBMIT_OK> before C<SUBMIT_UNWIND>.

=cut

sub SUBMIT_UNWIND {
    return '!@#unwind#@!';
}

=for html <a name="TIMEZONE_FIELD"></a>

=head2 TIMEZONE_FIELD : string

Returns field used in forms to set timezone.

=cut

sub TIMEZONE_FIELD {
    return 'tz';
}

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::Task;
use Bivio::IO::Trace;
use Bivio::SQL::FormSupport;
use Bivio::Type::SecretAny;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_TIMEZONE_COOKIE_FIELD) = Bivio::Agent::HTTP::Cookie->TIMEZONE_FIELD;

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

=for html <a name="clear_errors"></a>

=head2 clear_errors()

Remove any errors on fields on the form.

=cut

sub clear_errors {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{errors} = undef;
    return;
}

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

    # Save in request, so can be added to prev_context
    $req->put(ref($self) => $self, form_model => $self);

    # Called as an action internally, process values.  Do no validation.
    if ($values) {
	$self->internal_put($values);
	$fields->{literals} = {};
	_initialize_context($self, $req);
	$self->execute_input();
	return unless $fields->{errors};
	Carp::croak($self->as_string, ": called with invalid values");
    }

    my($input) = $req->get_form();

    # Parse context from the query string, if any
    my($query) = $req->unsafe_get('query');
    if ($query && $query->{fc}) {
	# If there is an incoming context, must be syntactically valid.
	my($c, $e) = Bivio::Type::SecretAny->from_literal($query->{fc});
	$self->die(Bivio::DieCode::CORRUPT_QUERY(),
		{field => 'fc', actual => $query->{fc},
		    error => $e}) unless $c;
	$fields->{context} = $c;
	# We don't want it to appear in any more URIs now that we can
	# store it in a form.
	delete($query->{fc});
	$req->put(query => undef) unless int(keys(%$query));
	_trace('context: ', $c) if $_TRACE;
    }

    # User didn't input anything, render blank form
    unless ($input) {
	$fields->{literals} = {};
	_initialize_context($self, $req) unless $fields->{context};
	$self->execute_empty;
	return;
    }

    # User submitted a form, parse, validate, and execute
    # Cancel causes an immediate redirect.  parse() returns false
    # on SUBMIT_UNWIND
    $fields->{literals} = $input;

    # Don't rollback, because unwind doesn't necessarily mean failure
    return unless _parse($self, $input);

    # If the form has errors, the transaction will be rolled back.
    # validate is always called so we try to return as many errors
    # to the user as possible.
    $self->validate();
    if ($fields->{errors}) {
	_put_file_field_reset_errors($self);
    }
    else {
	    # Try to catch and apply type errors thrown
	my($die) = Bivio::Die->catch(sub {$self->execute_input();});
	if ($die) {
	    # If not TypeError, just rethrow
	    $die->die() unless $die->get('code')->isa('Bivio::TypeError');
	    # Can we find the fields in the Form?
	    _apply_type_error($self, $die);
	}
	if ($fields->{errors}) {
	    _put_file_field_reset_errors($self);
	}
	else {
	    _redirect($self, 'next');
	    # DOES NOT RETURN
	}
    }
    # Some type of error, rollback and fall through to the next
    # task items.
    Bivio::Agent::Task->rollback;
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

=for html <a name="execute_other"></a>

=head2 execute_other(string button)

Processes the form after a cancel or other button is pressed.
The button string is passed.  It will redirect to the cancel
task for the form.

=cut

sub execute_other {
    return;
}

=for html <a name="execute_unwound"></a>

=head2 execute_unwound()

Called when the chained form returns and does a server_redirect
back to this form.

B<The form fields are not parsed.>  The values are left in their
literal state.

=cut

sub execute_unwound {
    return;
}

=for html <a name="format_context_as_query"></a>

=head2 static format_context_as_query(Bivio::Agent::Request req) : string

Calls L<get_context_from_request|"get_context_from_request"> and
formats as a query string value.

=cut

sub format_context_as_query {
    my($self, $req) = @_;
#TODO: Tightly coupled with Widget::Form which knows this is fc=
#      Need to understand better how to stop the context propagation
    return 'fc='.Bivio::Type::SecretAny->to_literal(
	    $self->get_context_from_request($req));
}

=for html <a name="get_context_from_request"></a>

=head2 static get_context_from_request(Bivio::Agent::Request hash_ref) : hash_ref

Returns the context elements extracted from the request as hash_ref.
If the form is I<redirecting> already, then the nested context
is returned.

=cut

sub get_context_from_request {
    my(undef, $req) = @_;
    my($model) = $req->unsafe_get('form_model');

    # If there is a model, make sure not redirecting
    if ($model) {
	my($fields) = $model->{$_PACKAGE};
	if ($fields->{redirecting}) {
	    # Just in case, clear the sentinel
	    $fields->{redirecting} = 0;

	    # If redirecting, return the stacked context if there is one
	    my($c) = $fields->{context};
	    $c = $c->{form_context} if $c;
	    _trace('unwound context: ', $c) if $_TRACE;
	    return $c;
	}
    }
    elsif ($model = $req->get('task')->get('form_model')) {
	$model = $model->get_instance;
    }

    # Construct a new context from existing state in request
    my($res) = {};
    foreach my $c (qw(uri form query form_context)) {
	$res->{$c} = $req->unsafe_get($c);
    }
    $res->{form_model} = ref($model);

    # Fix up file fields if any
    my($ff);
    if ($res->{form} && $model
	    && ($ff = $model->internal_get_file_field_names)) {
	# Need to copy, because we don't want to trash existing form.
	my($f) = {%{$res->{form}}};

	# Iterate over file fields
	foreach my $n (@$ff) {
	    my($fn) = $model->get_field_name_for_html($n);
	    # Converts to just the file name.  We'd never get this back,
	    # but we can stuff it into the form.  Widget::File
	    # knows how to handle this.
	    $f->{$fn} = $model->get_field_info($n, 'type')
		    ->to_literal($f->{$fn});
	    _trace($n, ': set value=', $f->{$fn}) if $_TRACE;
	}

	# Save new copy
	$res->{form} = $f;
    }

    _trace('new context: ', $res) if $_TRACE;
    return $res;
}

=for html <a name="get_errors"></a>

=head2 get_errors() : hash_ref

Returns the list of field errors.  C<undef> if no errors.

B<DO NOT MODIFY>.

=cut

sub get_errors {
    return shift->{$_PACKAGE}->{errors};
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
    return $self->get_field_info($name, 'type')->to_html($value)
	    if defined($value);
    my($fn) = $self->get_field_name_for_html($name);
    return Bivio::Util::escape_html(_get_literal($fields, $fn));
}

=for html <a name="get_field_as_literal"></a>

=head2 get_field_as_literal(string name) : string

Returns the field value.  If the field is in error and there
is no value, returns the literal value that was entered by
the user.

Always returns a valid string, but may be the empty string.

=cut

sub get_field_as_literal {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($value) = $self->unsafe_get($name);
    return $self->get_field_info($name, 'type')->to_literal($value)
	    if defined($value);
    my($fn) = $self->get_field_name_for_html($name);
    return _get_literal($fields, $fn);
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
    push(@res, version => $sql_support->get('version'));
    push(@res, context =>
	    Bivio::Type::SecretAny->to_literal($fields->{context}))
	    if $fields->{context};
    my($properties) = $self->internal_get();
    foreach my $n (@{$self->internal_get_hidden_field_names}) {
	my($fn) = $self->get_field_name_for_html($n);
	my($v) = defined($properties->{$n})
		? $self->get_field_info($n, 'type')
			->to_literal($properties->{$n})
		: _get_literal($fields, $fn);
	push(@res, $fn, $v);
    }
    return \@res;
}

=for html <a name="get_field_name_for_html"></a>

=head2 get_field_name_for_html(string name) : string

Get name for form appropriate to html.

=cut

sub get_field_name_for_html {
    return shift->get_field_info(shift, 'form_name');
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
    return shift->{$_PACKAGE}->{errors} ? 1 : 0;
}

=for html <a name="internal_clear_error"></a>

=head2 internal_clear_error(string property)

Clears the error on I<property> if any.

If I<property> is null, clears the "form" error.

=cut

sub internal_clear_error {
    my($self, $property) = @_;
    my($fields) = $self->{$_PACKAGE};
    return unless $fields->{errors};
    $property = '_' unless $property;
    delete($fields->{errors}->{$property});
    delete($fields->{errors}) unless %{$fields->{errors}};
    return;
}

=for html <a name="internal_field_constraint_error"></a>

=head2 internal_field_constraint_error(string property, Bivio::TypeError error)

This method is called when a DB constraint is encountered during the
form's execution.

The default action is a no-op.  The error is already "put" on the
field.

=cut

sub internal_field_constraint_error {
}

=for html <a name="internal_get_file_field_names"></a>

=head2 internal_get_file_field_names() : array_ref

B<Used internally to this module and ListFormModel.>

Returns I<file_field_names> attribute.

=cut

sub internal_get_file_field_names {
    return shift->internal_get_sql_support()->unsafe_get('file_field_names');
}

=for html <a name="internal_get_hidden_field_names"></a>

=head2 internal_get_hidden_field_names() : array_ref

B<Used internally to this module and ListFormModel.>

Returns I<hidden_field_names> attribute.

=cut

sub internal_get_hidden_field_names {
    return shift->internal_get_sql_support()->get('hidden_field_names');
}

=for html <a name="internal_get_literals"></a>

=head2 internal_get_literals() : hash_ref

B<Used internally to this module and ListFormModel.>

Returns the literals hash_ref.

=cut

sub internal_get_literals {
    return shift->{$_PACKAGE}->{literals};
}

=for html <a name="internal_get_visible_field_names"></a>

=head2 internal_get_visible_field_names() : array_ref

B<Used internally to this module and ListFormModel.>

Returns I<visible_field_names> attribute.

=cut

sub internal_get_visible_field_names {
    return shift->internal_get_sql_support()->get('visible_field_names');
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

=head2 static internal_initialize_sql_support(hash_ref config) : Bivio::SQL::Support

Returns the L<Bivio::SQL::FormSupport|Bivio::SQL::FormSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    my($proto, $config) = @_;
    die('cannot create anonymous PropertyModels') if $config;
    return Bivio::SQL::FormSupport->new($proto->internal_initialize);
}

=for html <a name="internal_pre_parse_columns"></a>

=head2 internal_pre_parse_columns()

B<Used internally to this module and ListFormModel.>

Called just before C<_parse_cols> is called, so C<ListFormModel> can
initialize its list_model to determine number of rows to expect.

=cut

sub internal_pre_parse_columns {
    return;
}

=for html <a name="internal_put_error"></a>

=head2 internal_put_error(string property, any error)

Associate I<error> with I<property>.

If I<property> is C<undef>, error applies to entire form.

I<error> must be a L<Bivio::TypeError|Bivio::TypeError> or
a name thereof.

=cut

sub internal_put_error {
    my($self, $property, $error) = @_;
    Carp::croak('too many args, literal deprecated') if int(@_) > 3;
    my($fields) = $self->{$_PACKAGE};
    $error = Bivio::TypeError->from_any($error);
    $property = '_' unless $property;
    _trace($property, ': ', $error->as_string) if $_TRACE;
    $fields->{errors} = {} unless $fields->{errors};
    $fields->{errors}->{$property} = $error;
    return;
}

=for html <a name="is_submit_ok"></a>

=head2 is_submit_ok(string button_value, hash_ref form) : boolean

Returns true if the button value is L<SUBMIT_OK|"SUBMIT_OK">.
Subclasses can override this, but probably don't need to.

If overriding, you must catch the L<SUBMIT_UNWIND|"SUBMIT_UNWIND">
if you don't want to render the form without errors in the event
of an unwind.

=cut

sub is_submit_ok {
    my($self, $value, $form) = @_;
    # Default is cancel

    # default to OK, submit isn't passed when user presses 'enter'
    return 1 unless defined($value) && length($value);

    # We assume it is a cancel if we don't get a match to ok
    # It is better than returning corrupt form for now.
    my($submit_ok) = $self->SUBMIT_OK;
    return 1 if $value eq $submit_ok;

    # If has same letters in same order, then is ok.
    $submit_ok =~ s/\s+//g;
    $value =~ s/\s+//g;
    return lc($value) eq lc($submit_ok) ? 1 : 0;
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

=for html <a name="put_context_fields"></a>

=head2 put_context_fields(string name, any value, ....)

Allows you to put multiple context fields on this form's context.

B<Does not work for I<in_list> ListForm fields unless you specify
the field name explicitly, e.g. RealmOwner.name.1>.

=cut

sub put_context_fields {
    my($self) = shift;
    Carp::croak("must be an even number of parameters")
		unless int(@_) && int(@_) % 2 == 0;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('form does not require_context') unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->{form_model};
    Carp::croak('context does not contain form_model') unless $model;

    my($mi) = $model->get_instance;
    # If there is no form, initialize
    my($f) = $c->{form} ||= {version => $mi->get_info('version')};
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	my($fn) = $mi->get_field_name_for_html($k);
	# Convert with to_literal--context->{form} is in raw form
	$f->{$fn} = $mi->get_field_info($k, 'type')->to_literal($v);
    }
    _trace('new form: ', $c->{form}) if $_TRACE;
    return;
}

=for html <a name="unsafe_get_context_field"></a>

=head2 unsafe_get_context_field(string name) : array

Returns the value of the context field.  Result is the same as
L<Bivio::Type::from_literal|Bivio::Type/"from_literal">.

Note: this is a heavy operation, because it converts the form value
each time.

=cut

sub unsafe_get_context_field {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('form does not require_context') unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->{form_model};
    Carp::croak('context does not contain form_model') unless $model;

    # If there is no form, can't be a value
    return (undef) unless $c->{form};

    # From the form_model's sql_support, get the type and return
    # the result of from_literal.
    my($mi) = $model->get_instance;
    my($type) = $mi->get_field_info($name, 'type');
    my($fn) = $mi->get_field_name_for_html($name);
    return $type->from_literal($c->{form}->{$fn});
}

=for html <a name="validate"></a>

=head2 validate()

By default this method does nothing. Subclasses should override it to provide
form specific validation.

C<validate> is always called, even if some of the fields do not
meet the SQL constraints.  This allows us to return as many errors
as possible to the user.

B<Care must be taken when checking fields, because they may be undef.>
In general, fields should not be checked by C<validate> if they are
C<undef>.

=cut

sub validate {
    return;
}

=for html <a name="validate_greater_than_zero"></a>

=head2 validate_greater_than_zero(string field)

Ensures the specified field is greater than 0. Puts an error on the form
if it fails.

=cut

sub validate_greater_than_zero {
    my($self, $field) = @_;
    my($value) = $self->get($field);
    return unless defined($value);

    $self->internal_put_error($field, Bivio::TypeError::GREATER_THAN_ZERO())
	    unless $value > 0;
    return;
}

=for html <a name="validate_not_negative"></a>

=head2 validate_not_negative(string field) : boolean

Ensures the specified field isn't negative. Puts an error on the form
if it fails.

=cut

sub validate_not_negative {
    my($self, $field) = @_;
    my($value) = $self->get($field);
    return unless defined($value);

    $self->internal_put_error($field, Bivio::TypeError::NOT_NEGATIVE())
	    unless $value >= 0;
    return;
}

=for html <a name="validate_not_null"></a>

=head2 validate_not_null(string field)

Ensures the specified field isn't undef. Puts an error on the form
if it fails.

=cut

sub validate_not_null {
    my($self, $field) = @_;
    my($value) = $self->get($field);

    $self->internal_put_error($field, Bivio::TypeError::NULL())
	    unless defined($value);
    return;
}

#=PRIVATE METHODS

# _apply_type_error(Bivio::Biz::FormModel self, Bivio::Die die)
#
# Looks up the columns and table in this form model.  If found,
# applies the errors to the form model.
#
sub _apply_type_error {
    my($self, $die) = @_;
    my($err, $attrs) = $die->get('code', 'attrs');
    my($table, $columns) = @{$attrs}{'table','columns'};
    $die->die() unless defined($table);
    my($sql_support) = $self->internal_get_sql_support();
    my($models) = $sql_support->get('models');
    my($got_one) = 0;
    foreach my $n (sort(keys(%$models))) {
	my($m) = $models->{$n}->{instance};
	next unless $table eq $m->get_info('table_name');
	foreach my $c (@$columns) {
	    my($my_col) = "$n.$c";
	    if ($sql_support->has_columns($my_col)) {
		$got_one = 1;
		$self->internal_put_error($my_col, $err);
		$self->internal_field_constraint_error($my_col, $err);
	    }
	}
    }
    $die->die() unless $got_one;
    return;
}

# _get_literal(hash_ref fields, string form_name) : string
#
# Returns the literal value of the named form field.  Special care
# is taken to return only the filename attribute of complex form fields.
#
sub _get_literal {
    my($fields, $form_name) = @_;
    my($value) = $fields->{literals}->{$form_name};
    return '' unless defined($value);
    return $value unless ref($value);

    # If a complex form field has a filename, return it.  Otherwise,
    # return nothing.  We never returnn the "content" back to the user
    # with FileFields.
    return defined($value->{filename}) ? $value->{filename} : '';
}

# _initialize_context(Bivio::Biz::FormModel self, Bivio::Agent::Request req)
#
# If "self" does not have context, does nothing (context is undef).
# Else, initialize the context to the "next" task unless the context
# is passed in from the req.
#
sub _initialize_context {
    my($self, $req) = @_;
    my($sql_support) = $self->internal_get_sql_support();
    return unless $sql_support->get('require_context');

    my($c) = $req->unsafe_get('form_context');
    unless ($c) {
	my($next) = $req->get('task')->get('next');
	my($form_model) = Bivio::Agent::Task->get_by_id($next)
		->get('form_model');
	$c = {
	    form_model => $form_model,
	    uri => $req->format_stateless_uri($next),
	    query => undef,
	    # Only create a form if there is a form_model on next task
	    form => undef,
	    form_context => undef,
	};
    }
    $self->{$_PACKAGE}->{context} = $c;
    _trace('context: ', $c) if $_TRACE;
    return;
}

# _parse(Bivio::Biz::FormModel self, hash_ref form) : boolean
#
# Parses the form. If Cancel or Other is encountered, redirects immediately.
# If it is SUBMIT_UNWIND, returns false.  If it is ok, returns true.
#
sub _parse {
    my($self, $form) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Clear any incoming errors
    delete($fields->{errors});
    my($sql_support) = $self->internal_get_sql_support;
    _trace("form = ", $form) if $_TRACE;
    _parse_version($self, $form->{version}, $sql_support);
    # Parse context first, so can be used by parse_submit (is_submit_ok)
    _parse_context($self, $form) if $sql_support->get('require_context');
    # Ditto for timezone
    _parse_timezone($self, $form->{TIMEZONE_FIELD()});

    # parse, but only save errors if it is a submit
    my($is_submit) = _parse_submit($self, $form);
    my($values) = {};

    # Allow ListFormModel to initialize its state
    $self->internal_pre_parse_columns();

    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);
    delete($fields->{errors}) unless ($is_submit);
    return $is_submit;
}

# _parse_col(Bivio::Biz::FormModel self, hash_ref form, Bivio::SQL::FormSupport sql_support, hash_ref values, boolean is_hidden)
#
# Parses the form field and returns the value.  Stores errors in the
# fields->{errors}.
#
sub _parse_cols {
    my($self, $form, $sql_support, $values, $is_hidden) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($method) = $is_hidden ? 'internal_get_hidden_field_names'
	    : 'internal_get_visible_field_names';
    foreach my $n (@{$self->$method()}) {
	my($fn) = $self->get_field_name_for_html($n);

	# Handle complex form fields.  Avoid copies of huge data, so
	# don't assign to temporary until kind (complex/simple) is known.
	if (ref($form->{$fn})) {
	    my($fv) = $form->{$fn};
	    # Was there an error in Bivio::Agent::HTTP::Form
	    if ($fv->{error}) {
		$self->internal_put_error($n, $fv->{error});
		next;
	    }

	    # Not expecting a complex form field?
	    unless ($self->get_field_info($n, 'is_file_field')) {
		# Be friendly and let the guy set the content this way.
		# We don't really know how browser handle things like this.
		if (length(${$fv->{content}}) > $self->MAX_FIELD_SIZE()) {
		    $self->internal_put_error($n, 'TOO_LONG');
		    next;
		}
		# Only FileFields know how to handle complex field values.
		# Revert to simple field value.
		$form->{$fn} = ${$fv->{content}};
	    }
	}
	# Make sure the simple field isn't too large
	elsif (defined($form->{$fn})
		&& length($form->{$fn}) > $self->MAX_FIELD_SIZE()) {
	    $self->internal_put_error($n, 'TOO_LONG');
	    next;
	}

	# Finally, parse the value
	my($v, $err) = $self->get_field_info($n, 'type')
		->from_literal($form->{$fn});
	$values->{$n} = $v;

	# Success?
	if (defined($v)) {
	    # Zero field ok?
	    next unless $self->get_field_info($n, 'constraint')
		    == Bivio::SQL::Constraint::NOT_ZERO_ENUM();
	    next if $v->as_int != 0;
	    $err = Bivio::TypeError::UNSPECIFIED();
	}

	# Null field ok?
	unless ($err) {
	    next if $self->get_field_info($n, 'constraint')
		    == Bivio::SQL::Constraint::NONE();
	    $err = Bivio::TypeError::NULL();
	}

	# Error in field.  Save the original value.
	if ($is_hidden) {
	    $self->die(Bivio::DieCode::CORRUPT_FORM(),
		    {field => $n, actual => $form->{$fn}, error => $err});
	}
	else {
	    $self->internal_put_error($n, $err);
	}
    }
    return;
}

# _parse_context(Bivio::Biz::FormModel self, string value, hash_ref form, Bivio::SQL::FormSupport sql_support)
#
# Parses the form's context.  If there is no context, creates it.
# ONLY CALL IF require_context
#
sub _parse_context {
    my($self, $form) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($form->{context}) {
	# If there is an incoming context, must be syntactically valid.
	# Overwrites the query context, if any
	my($c, $e) = Bivio::Type::SecretAny->from_literal($form->{context});
	$self->die(Bivio::DieCode::CORRUPT_FORM(),
		{field => 'context', actual => $form->{context},
		    error => $e}) unless $c;
	$self->{$_PACKAGE}->{context} = $c;
    }
    else {
	# OK, to not have incoming context unless have it from query
	_initialize_context($self) unless $fields->{context};
    }
    _trace('context: ', $fields->{context}) if $_TRACE;
    return;
}

# _parse_submit(Bivio::Biz::FormModel self, string value, hash_ref form) : boolean
#
# Parses the submit button.  If there is an error, throws CORRUPT_FORM.
# If the button is Cancel, will redirect immediately.  If the button
# is "OK", returns true.  If the button is SUBMIT_UNWIND, returns false.
#
#
sub _parse_submit {
    my($self, $form) = @_;
    my($value) = $form->{$self->SUBMIT};

    # Is the button an OK?
    # If SUBMIT_UNWIND is the same as SUBMIT_OK, will act as OK.
    return 1 if $self->is_submit_ok($value, $form);

    # It wasn't an ok, if SUBMIT_UNWIND, then don't parse the form.
    if ($self->SUBMIT_UNWIND eq $value) {
	_trace('unwind button, not parsing form') if $_TRACE;
	return 0;
    }

    # Cancel or other doesn't parse form, but allows the subclass
    # to do something on cancel, e.g. clear a cookie.
    _trace('cancel or other button: ', $value) if $_TRACE;

    my($req) = $self->get_request;
    $self->execute_other($value);

    # client redirect on cancel, no state is saved
    _redirect($self, 'cancel');
    # DOES NOT RETURN
}

# _parse_timezone(Bivio::Biz::FormModel self, string value)
#
# If it is set, will set in cookie.  Otherwise, not set in cookie.
#
sub _parse_timezone {
    my($self, $value) = @_;

    # Parse the integer
    my($v) = Bivio::Type::Integer->from_literal($value);
    # Only go on if could parse.   Otherwise, other modules know how
    # to handle timezone as undef.
    return unless defined($v);

    my($req) = $self->get_request;
    Bivio::Agent::HTTP::Cookie->set_field($req, $_TIMEZONE_COOKIE_FIELD, $v);
    $req->put(timezone => $v);
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

# _put_file_field_reset_errors(Bivio::Biz::FormModel self)
#
# Puts FILE_FIELD_RESET_FOR_SECURITY on file fields not in error.
#
sub _put_file_field_reset_errors {
    my($self) = @_;
    # If there were errors, provide feedback to the user about
    # file fields which are special.
    my($file_fields) = $self->internal_get_file_field_names;
    return unless $file_fields;

    my($fields) = $self->{$_PACKAGE};
    my($properties) = $self->internal_get;
    foreach my $n (@$file_fields) {
	# Don't replace an existing error
	next unless defined($properties->{$n}) && !$fields->{errors}->{$n};

	# Tells user that we didn't clear the field, the browser did.
	$self->internal_put_error($n,
		Bivio::TypeError::FILE_FIELD_RESET_FOR_SECURITY())
    }
    return;
}

# _redirect(Bivio::Biz::FormModel self, string which) : 
#
# Redirect to the "next" or "cancel" task depending on "which" if there
# is no context.  Otherwise, redirect to context.
#
sub _redirect {
    my($self, $which) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Success, redirect to the next task or to the task in
    # the context.
    my($req) = $self->get_request;
    $req->client_redirect($req->get('task')->get($which))
	    unless $fields->{context};

    my($c) = $fields->{context};
    my($f) = $c->{form};
    unless ($f) {
	_trace('no form, client_redirect: ', $c->{uri},
		'?', $c->{query}) if $_TRACE;
	# If there is no form, redirect to client so looks
	# better.
	$req->client_redirect(@{$c}{qw(uri query)});
	# DOES NOT RETURN
    }

    # Do an server redirect to context, because can't do
    # client redirect (no way to pass form state (reasonably)).
    # Indicate to the next form that this is a SUBMIT_UNWIND
    # Make sure you use that form's SUBMIT_UNWIND button.
    $f->{$self->SUBMIT} = $c->{form_model}->SUBMIT_UNWIND;

    # Ensure this form_model is seen as the redirect model
    # by get_context_from_request and set a flag so it
    # knows to pop context instead of pushing.
    $req->put(form_model => $self);
    $fields->{redirecting} = 1;

    # Redirect calls us back in get_context_from_request
    _trace('have form, server_redirect: ', $c->{uri},
	    '?', $c->{query}) if $_TRACE;
    $req->server_redirect(@{$c}{qw(uri query)}, $f);
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
