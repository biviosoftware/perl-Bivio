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

    my($input) = $req->unsafe_get('form');

    # User didn't input anything, render blank form
    unless ($input) {
	$fields->{literals} = {};
	_initialize_context($self, $req);
	$self->execute_empty;
	return;
    }

    # User submitted a form, parse, validate, and execute
    # Cancel causes an immediate redirect.  parse() returns false
    # on SUBMIT_UNWIND
    $fields->{literals} = $input;

    # Don't rollback, because unwind doesn't necessarily mean failure
    return unless _parse($self, $input);

    # If the form has errors, the transaction will be rolled back
    unless ($fields->{errors}) {
	$self->validate();
	unless ($fields->{errors}) {
	    # Try to catch and apply type errors thrown
	    my($die) = Bivio::Die->catch(sub {$self->execute_input();});
	    if ($die) {
		# If not TypeError, just rethrow
		$die->die() unless $die->get('code')->isa('Bivio::TypeError');
		# Can we find the fields in the Form?
		_apply_type_error($self, $die);
	    }
	    unless ($fields->{errors}) {
		# Success, redirect to the next task or to the task in
		# the context.
		my($req) = $self->get_request;
		$req->client_redirect($req->get('task')->get('next'))
			unless $fields->{context};

		my($f) = $fields->{context}->{form};
		unless ($f) {
		    _trace('no form, client_redirect: ',
			    $fields->{context}->{uri},
			    '?', $fields->{context}->{query}) if $_TRACE;
		    # If there is no form, redirect to client so looks
		    # better.
		    $req->client_redirect(
			    @{$fields->{context}}{qw(uri query)});
		    # DOES NOT RETURN
		}

		# Do an server redirect to context, because can't do
		# client redirect (no way to pass form state (reasonably)).
		# Indicate to the next form that this is a SUBMIT_UNWIND
		$f->{$self->SUBMIT} = $self->SUBMIT_UNWIND;

		# Ensure this form_model is seen as the redirect model
		# by get_context_from_request and set a flag so it
		# knows to pop context instead of pushing.
		$req->put(form_model => $self);
		$fields->{redirecting} = 1;

		# Redirect calls us back in get_context_from_request
		_trace('have form, server_redirect: ',
			$fields->{context}->{uri},
			'?', $fields->{context}->{query}) if $_TRACE;
		$req->server_redirect(
			@{$fields->{context}}{qw(uri query)}, $f);
		# DOES NOT RETURN
	    }
	}
    }
    # Some type of error, rollback and put self so can render form again
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

=for html <a name="get_context_from_request"></a>

=head2 static get_context_from_request(Bivio::Agent::Request req) : hash_ref

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

    # Construct a new context from existing state in request
    my($res) = {};
    foreach my $c (qw(uri form query form_context)) {
	$res->{$c} = $req->unsafe_get($c);
    }
    $res->{form_model} = ref($model);
    _trace('new context: ', $res) if $_TRACE;
    return $res;
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
    my($fn) = $self->get_field_info($name, 'form_name');
    return '' unless defined($fields->{literals}->{$fn});
    return Bivio::Util::escape_html($fields->{literals}->{$fn});
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
    my($literals) = $fields->{literals};
    foreach my $col (@{$sql_support->get('hidden')}) {
	my($n) = $col->{name};
	my($v) = $col->{type}->to_literal($properties->{$n});
        $v = defined($literals->{$col->{form_name}})
		? $literals->{$col->{form_name}} : '' unless defined($v);
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
    my($other_cols) = $mi->get_info('columns');
    # If there is no form, initialize
    my($f) = $c->{form} ||= {version => $mi->get_info('version')};
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	my($col) = $other_cols->{$k};
	Carp::croak("$model.$k: no such field") unless $col;
	# Convert with to_literal--context->{form} is in raw form
	$f->{$col->{form_name}} = $col->{type}->to_literal($v);
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
    my($fn) = $mi->get_field_info($name, 'form_name');
    return $type->from_literal($c->{form}->{$fn});
}

=for html <a name="validate"></a>

=head2 validate()

By default this method does nothing. Subclasses should override it to provide
form specific validation.

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
    my($value) = $self->internal_get()->{$field};
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
    my($value) = $self->internal_get()->{$field};
    return unless defined($value);

    $self->internal_put_error($field, Bivio::TypeError::NOT_NEGATIVE())
	    unless $value >= 0;
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
	    }
	}
    }
    $die->die() unless $got_one;
    return;
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

    # Parse only if parse_submit says it is ok to parse
    return 0 unless _parse_submit($self, $form);
    my($values) = {};
    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);
    return 1;
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
	if (defined($v)) {
	    # Zero field ok?
	    next unless $col->{constraint}
		    == Bivio::SQL::Constraint::NOT_ZERO_ENUM();
	    next if $v->as_int != 0;
	    $err = Bivio::TypeError::UNSPECIFIED();
	}
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
	    $self->internal_put_error($col->{name}, $err);
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

    if ($form->{context}) {
	# If there is an incoming context, must be syntactically valid.
	my($c, $e) = Bivio::Type::SecretAny->from_literal($form->{context});
	$self->die(Bivio::DieCode::CORRUPT_FORM(),
		{field => 'context', actual => $form->{context},
		    error => $e}) unless $c;
	$self->{$_PACKAGE}->{context} = $c;
    }
    else {
	# OK, to not have incoming context.
	_initialize_context($self);
    }
    _trace('context: ', $self->{$_PACKAGE}->{context}) if $_TRACE;
    return;
}

# _parse_submit(Bivio::Biz::FormModel self, string value, hash_ref form) : boolean
#
# Parses the submit button.  If there is an error, throws CORRUPT_FORM.
# If the button is Cancel, will redirect immediately.  If the button
# is "OK", returns true.  If the button is SUBMIT_UNWIND, returns false.
#
sub _parse_submit {
    my($self, $form) = @_;
    my($value) = $form->{$self->SUBMIT};

    # Is the button an OK?
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
    $req->client_redirect($req->get('task')->get('cancel'));
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
