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
L<execute_ok|"execute_ok"> is called.

A form may have a context.  This is specified by the C<require_context> in
L<internal_initialize_sql_support|"internal_initialize_sql_support">.  The
context is how we got to this form, e.g. from another form and the contents of
that form.  Forms with context return to the uri specified in the context on
"ok" completion.  If the request has FormModel.require_context set to false,
no context will be required.  If the task has require_context set to false
and this is the primary form (Task.form_model), no context will be required.

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

Form field errors are always one of the enums in
L<Bivio::TypeError|Bivio::TypeError>.

Free text input widgets (Text and TextArea) retrieve field values with
L<get_field_as_html|"get_field_as_html">, because the field may be in error
and the errant literal value may not be valid for the type.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CONTEXT_FIELD"></a>

=head2 CONTEXT_FIELD : string

Returns "context".

=cut

sub CONTEXT_FIELD {
    return 'c';
}

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

=for html <a name="TIMEZONE_FIELD"></a>

=head2 TIMEZONE_FIELD : string

Returns field used in forms to set timezone.

=cut

sub TIMEZONE_FIELD {
    return 'tz';
}

=for html <a name="VERSION_FIELD"></a>

=head2 VERSION_FIELD : string

Returns 'version'

=cut

sub VERSION_FIELD {
    return 'v';
}

#=IMPORTS
use Bivio::Die;
use Bivio::HTML;
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::Task;
use Bivio::Biz::FormContext;
use Bivio::IO::Trace;
use Bivio::SQL::FormSupport;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_TIMEZONE_COOKIE_FIELD) = Bivio::Agent::HTTP::Cookie->TIMEZONE_FIELD;
Bivio::Agent::HTTP::Cookie->register($_PACKAGE);

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
	stay_on_page => 0,
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

=head2 static execute(Bivio::Agent::Request req) : boolean

=head2 static execute(Bivio::Agent::Request req, hash_ref values) : boolean

There are two modes:

=over 4

=item html form

I<values> is not passed.  Form values are processed from I<req.form>.
Loads a new instance of this model using the request.
If the form processing ends in errors, any transactions are rolled back.

The value I<form_model> is "put" on I<req> in this case only.

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
    return $proto->new($req)->process($req, $values);
}

=for html <a name="execute_cancel"></a>

=head2 execute_cancel(string button_field) : boolean

Default cancel processing, redirects to the cancel task.

=cut

sub execute_cancel {
    my($self, $button_field) = @_;
    # client redirect on cancel, no state is saved
    _redirect($self, 'cancel');
}


=for html <a name="execute_empty"></a>

=head2 execute_empty() : boolean

Processes an empty form.  By default is a no-op.

B<Return true if you want the Form to execute immediately>

=cut

sub execute_empty {
    return 0;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok(string button_field) : boolean

Processes the form after validation.  By default is an no-op.

B<Return true if you want the Form to exit immediately.>

=cut

sub execute_ok {
    return 0;
}

=for html <a name="execute_other"></a>

=head2 execute_other(string button_field) : boolean

Processes the form after a cancel or other button is pressed.
The button string is passed.  It will redirect to the cancel
task for the form.

Although it is unlikely, you'll ever want to do this.
Return true if you want the Form to execute immediately.

=cut

sub execute_other {
    return 0;
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind() : boolean

Called in the L<SUBMIT_UNWIND|"SUBMIT_UNWIND"> case.  The form
is already parsed, but not validated.  You cannot assume any
fields are valid.

This method is called right before L<execute|"execute"> is
about to return.  You can modify fields with
L<internal_put_field|"internal_put_field">.

Although it is unlikely, you'll ever want to do this.
Return true if you want the Form to execute immediately.

=cut

sub execute_unwind {
    return 0;
}

=for html <a name="format_context_as_query"></a>

=head2 static format_context_as_query(Bivio::Agent::Request req, Bivio::Agent::TaskId uri_task) : string

B<Only to be called by Bivio::Agent::HTTP::Location.>

Calls L<get_context_from_request|"get_context_from_request"> and
formats as a query string value with a '?' prefix.

=cut

sub format_context_as_query {
    my($self, $req, $uri_task) = @_;
    my($c) = $self->get_context_from_request($req, 1);

    # If the task we are going to is the same as the unwind task,
    # don't render the context.  Prevents infinite recursion.
    # If we don't have an unwind task, we don't return a context
    return '' if !$c->{unwind_task} || $c->{unwind_task} == $uri_task;

#TODO: Tightly coupled with Widget::Form which knows this is fc=
#      Need to understand better how to stop the context propagation
    return '?fc='.Bivio::HTML->escape_query(
	    Bivio::Biz::FormContext->to_literal($req, $c));
}

=for html <a name="get_button_submitted"></a>

=head2 get_button_submitted() : string

Returns the name of the button field selected. This value is valid only
after L<execute|"execute"> has been invoked.

=cut

sub get_button_submitted {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{button_submitted};
}

=for html <a name="get_context_from_request"></a>

=head2 static get_context_from_request(Bivio::Agent::Request hash_ref, boolean no_form) : hash_ref

Returns the context elements extracted from the request as hash_ref.
If the form is I<redirecting> already, then the nested context
is returned.

If I<no_form> is true, we don't add in the form to the context.  This is used
by L<format_context_as_query|"format_context_as_query"> to limit
the size.

=cut

sub get_context_from_request {
    my(undef, $req, $no_form) = @_;
    my($model) = $req->unsafe_get('form_model');

    # If there is a model, make sure not redirecting
    my($form, $context);
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
#TODO: This is horribly inefficient, I think.
	$form = $model->internal_get_field_values;
	$context = $model->{$_PACKAGE}->{context};
	_trace('from model: ', $form) if $_TRACE;
    }
    elsif ($model = $req->get('task')->get('form_model')) {
	$model = $model->get_instance;
	$form = $req->unsafe_get('form');
	_trace('from request: ', $form) if $_TRACE;
    }

    $context = $form = undef if $no_form;

    # Construct a new context from existing state in request.
    # This code is coupled with FormContext.
    my($res) = {
	form_model => ref($model),
	form => $form,
	form_context => $context,
	query => $req->unsafe_get('query'),
	path_info => $req->unsafe_get('path_info'),
	unwind_task => $req->unsafe_get('task_id'),
	cancel_task => $req->get('task')->unsafe_get('cancel'),
	realm => $req->get('auth_realm'),
    };

    # Fix up file fields if any
    my($ff);
    if ($form && $model
	    && ($ff = $model->internal_get_file_field_names)) {
	# Need to copy, because we don't want to trash existing form.
	my($f) = {%$form};

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
    return Bivio::HTML->escape(_get_literal($fields, $fn));
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
    push(@res, VERSION_FIELD() => $sql_support->get('version'));
    push(@res, CONTEXT_FIELD() => Bivio::Biz::FormContext->to_literal(
	    $self->get_request, $fields->{context}))
	    if $fields->{context};
    my($properties) = $self->internal_get();
    foreach my $n (@{$self->internal_get_hidden_field_names}) {
	push(@res, $self->get_field_name_for_html($n),
		$self->get_field_as_literal($n));
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

=for html <a name="handle_cookie_in"></a>

=head2 handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Looks for timezone in I<cookie> and sets I<timezone> on I<req>.

=cut

sub handle_cookie_in {
    my($self, $cookie, $req) = @_;
    my($v) = $cookie->unsafe_get($_TIMEZONE_COOKIE_FIELD);
    $req->put(timezone => $v) if defined($v);
    return;
}

=for html <a name="has_context_field"></a>

=head2 has_context_field(string name) : boolean

Returns true if there is a form in the context and it has a context
field I<name>.

=cut

sub has_context_field {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return 0 unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->{form_model};
    return 0 unless $model;

    # From the form_model's sql_support, get the type and return
    # the result of from_literal.
    my($mi) = $model->get_instance;
    return $mi->has_fields($name);
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

=for html <a name="internal_clear_literal"></a>

=head2 internal_clear_literal(string property)

Clears I<property>'s literal value.

=cut

sub internal_clear_literal {
    my($self, $property) = @_;
    my($fields) = $self->{$_PACKAGE};
    _put_literal($fields, $self->get_field_name_for_html($property), '');
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

=for html <a name="internal_get_field_values"></a>

=head2 internal_get_field_values() : hash_ref

Returns the form as literals

=cut

sub internal_get_field_values {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($properties) = $self->internal_get;
    my($res) = {
	VERSION_FIELD() => $self->get_info('version'),
	TIMEZONE_FIELD() => $fields->{literals}->{TIMEZONE_FIELD()},
    };
    foreach my $n (@{$self->internal_get_hidden_field_names},
	   @{$self->internal_get_visible_field_names}) {
	$res->{$self->get_field_name_for_html($n)}
		= $self->get_field_as_literal($n);
    }
    return $res;
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

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {

    return {
	visible => [
	    {
		name => 'ok_button',
		type => 'OKButton',
		constraint => 'NONE',
	    },
	    {
		name => 'cancel_button',
		type => 'CancelButton',
		constraint => 'NONE',
	    },
	],
    };
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
    $config = $proto->internal_initialize;
    $config->{class} = ref($proto) || $proto;
    return Bivio::SQL::FormSupport->new($config);
}

=for html <a name="internal_post_execute"></a>

=head2 internal_post_execute(string method)

Called to initialize info I<after> a validate_and_execute_ok, execute_empty,
execute_unwind, execute_other, or execute_cancel.

This routine must be robust against data errors and the like.
I<method> is which method was just invoked, if the method did not
end in an exception (including redirects).

Does nothing by default.

See also L<internal_pre_execute|"internal_pre_execute">.

=cut

sub internal_post_execute {
    return;
}

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute(string method)

Called to initialize info before a validate_and_execute_ok, execute_empty,
execute_unwind, execute_other, or execute_cancel.

This routine must be robust against data errors and the like.
I<method> is which method that is about to be invoked.

Does nothing by default.

See also L<internal_post_execute|"internal_post_execute">.

=cut

sub internal_pre_execute {
    return;
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

=for html <a name="internal_put_field"></a>

=head2 internal_put_field(string property, any value)

Puts a value on a field.  No validation checking.

=cut

sub internal_put_field {
    my($self, $property, $value) = @_;
    $self->internal_get->{$property} = $value;
    return;
}

=for html <a name="internal_redirect_next"></a>

=head2 internal_redirect_next()

Redirects to the next form task. This can be used to double unwind
a form context, popping another level when called from
L<execute_unwind|"execute_unwind">.

=cut

sub internal_redirect_next {
    my($self) = @_;
    _redirect($self, 'next');
    return;
}

=for html <a name="internal_stay_on_page"></a>

=head2 internal_stay_on_page()

Directs the form to remain on the current page regardless of the error state.
Any changes are committed to the database. This is useful for non-submit
buttons which need to perform calculations on the current data.

=cut

sub internal_stay_on_page {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{stay_on_page} = 1;
    return;
}

=for html <a name="is_field_editable"></a>

=head2 is_field_editable(string field) : boolean

Returns true if the field is editable. By default all fields are editable,
subclasses may override this to provide this value dynamically.

=cut

sub is_field_editable {
    return 1;
}

=for html <a name="load_from_model_properties"></a>

=head2 load_from_model_properties(string model)

=head2 load_from_model_properties(Bivio::Biz::Model model)

Gets I<model> and copies all properties from I<model> to I<properties>.
If I<model> is not a reference, calls L<get_model|"get_model"> first.

=cut

sub load_from_model_properties {
    my($self, $model) = @_;
    my($sql_support) = $self->internal_get_sql_support();
    my($models) = $sql_support->get('models');
    my($m);
    if (ref($model)) {
	$m = $model;
	$model = $m->simple_package_name;
    }
    else {
	$self->die($model, ': no such model')
		unless defined($models->{$model});
	$m = $self->get_model($model);
    }
    my($properties) = $self->internal_get();
    my($column_aliases) = $sql_support->get('column_aliases');
    foreach my $cn (@{$models->{$model}->{column_names_referenced}}) {
#TODO: Document this is being used elsewhere!
	my($pn) = $column_aliases->{$model.'.'.$cn}->{name};
	# Copy the model's property to this model
	$properties->{$pn} = $m->get($cn);
    }
    return;
}

=for html <a name="process"></a>

=head2 process(Bivio::Agent::Request req) : boolean

=head2 process(Bivio::Agent::Request req, hash_ref values) : boolean

Does the work for L<execute|"execute"> after execute creates a I<self>.

=cut

sub process {
    my($self, $req, $values) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Save in request
    $self->put_on_request;

    # Called as an action internally, process values.  Do no validation.
    if ($values) {
	$self->internal_put($values);
	$fields->{literals} = {};
	# Forms called internally don't have a context.  Form models
	# should blow up.
	return 1 if _call_execute($self, 'execute_ok', 'ok_button');
	return 0 unless $fields->{errors};
	if ($_TRACE) {
	    my($msg) = '';
	    foreach my $field (keys(%{$fields->{errors}})) {
		$msg .= $field.' '.$fields->{errors}->{$field}->get_name."\n";
	    }
	    _trace($msg);
	}
	Bivio::Die->die($self->as_string,
		": called with invalid values");
	# DOES NOT RETURN
    }

    # Is this a primary or auxiliary form on the request?
    my($task) = $req->get('task');
    my($primary_class) = $task->get('form_model');
    $fields->{require_context} = $self->get_info('require_context')
	    && $req->get_or_default(ref($self).'.'
		    .'require_context', 1);
    if (defined($primary_class) && $primary_class eq ref($self)) {
	# Primary forms don't require context if task doesn't require
	# context.
	$fields->{require_context} = 0 unless $task->get('require_context');
	_trace(ref($self), ': primary form') if $_TRACE;
    }
    else {
	# Auxiliary forms are not the "main" form models on the page
	# and therefore, do not have any input.  They always return
	# back to this page, if they require_context.
	_trace(ref($self), ': auxiliary form') if $_TRACE;
	$fields->{literals} = {};
	$fields->{context} = $self->get_context_from_request($req)
		if $fields->{require_context};
	return _call_execute($self, 'execute_empty');
    }

    # Only save "generically" if not executed explicitly.
    # sub-forms shouldn't be put on as THE form_model.  Should appear
    # before $req->get_form for security reasons (see
    # Bivio::Agent::Request->as_string).
    $req->put(form_model => $self);

    my($input) = $req->get_form();

    # Parse context from the query string, if any
    my($query) = $req->unsafe_get('query');
    if ($query && $query->{fc}) {
	# If there is an incoming context, must be syntactically valid.
	my($c) = Bivio::Biz::FormContext->from_literal(
		$self, $query->{fc});
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
	$fields->{context} = _initial_context($self, $req)
		unless $fields->{context};
	return _call_execute($self, 'execute_empty');
    }

    # User submitted a form, parse, validate, and execute
    # Cancel causes an immediate redirect.  parse() returns false
    # on SUBMIT_UNWIND
    $fields->{literals} = $input;

    unless (_parse($self, $input)) {
	# Allow the subclass to modify the state of the form after an unwind
	$self->clear_errors;
	return _call_execute($self, 'execute_unwind');
    }

    # determine the selected button, default is ok
    my($button, $button_type) = ('ok_button', 'Bivio::Type::OKButton');
    foreach my $field (@{$self->get_keys}) {
	if (defined($self->get($field))) {
	    my($type) = $self->get_field_type($field);
	    ($button, $button_type) = ($field, $type)
		    if $type->isa('Bivio::Type::FormButton');
	}
    }
    $fields->{button_submitted} = $button;

    return $self->validate_and_execute_ok($button)
	    if $button_type->isa('Bivio::Type::OKButton');

    return _call_execute($self, 'execute_cancel', $button)
	    if $button_type->isa('Bivio::Type::CancelButton');

    return _call_execute($self, 'execute_other', $button);
}

=for html <a name="put_context_fields"></a>

=head2 put_context_fields(string name, any value, ....)

Allows you to put multiple context fields on this form's context.

B<Does not work for I<in_list> ListForm fields unless you specify
the field name explicitly, e.g. RealmOwner.name.1>.

=cut

sub put_context_fields {
    my($self) = shift;
    # Allow zero fields (see _redirect)
    Carp::croak("must be an even number of parameters")
		unless int(@_) % 2 == 0;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('form does not require_context') unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->{form_model};
    Carp::croak('context does not contain form_model') unless $model;

    my($mi) = $model->get_instance;
    # If there is no form, initialize
    my($f) = $c->{form} ||= {VERSION_FIELD() => $mi->get_info('version')};
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	my($fn) = $mi->get_field_name_for_html($k);
#TODO: CreditCardNumber isn't going to work here.
	# Convert with to_literal--context->{form} is in raw form
	$f->{$fn} = $mi->get_field_info($k, 'type')->to_literal($v);
    }
    _trace('new form: ', $c->{form}) if $_TRACE;
    return;
}

=for html <a name="unsafe_get_context"></a>

=head2 unsafe_get_context(string attr) : any

Returns the attribute from the context.  If not in context,
returns C<undef>.

Valid attributes are:

=over 4

=item unwind_task : Bivio::Agent::TaskId

=item cancel_task : Bivio::Agent::TaskId

=back

=cut

sub unsafe_get_context {
    my($self, $attr) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Nothing in context or form doesn't support context
    return undef unless $fields->{context};

    # Very strict, because we don't want the caller to modify the context.
    $self->throw_die('DIE', {message => 'invalid context attribute',
	entity => $attr})
	    unless $attr =~ /_task$/ && exists($fields->{context}->{$attr});
    return $fields->{context}->{$attr};
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
    return undef unless $model;

    # If there is no form, can't be a value
    return undef unless $c->{form};

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

=for html <a name="validate_and_execute_ok"></a>

=head2 validate_and_execute_ok(string form_button) : boolean

Validates the form, calling L<validate|"validate">, then executes
it, catching any exceptions and adding them to errors. Rolls back
changes on errors.

=cut

sub validate_and_execute_ok {
    my($self, $form_button) = @_;
    my($fields) = $self->{$_PACKAGE};

    # If the form has errors, the transaction will be rolled back.
    # validate is always called so we try to return as many errors
    # to the user as possible.
    $self->internal_pre_execute('validate_and_execute_ok');
    $self->validate();
    if ($fields->{errors}) {
	_put_file_field_reset_errors($self);
    }
    else {
	# Catch errors and rethrow unless we can process
	my($res);
	my($die) = Bivio::Die->catch(sub {
	        $res = $self->execute_ok($form_button);});
	if ($die) {
	    if ($die->get('code')->isa('Bivio::TypeError')) {
		# Type errors are "normal"
		_apply_type_error($self, $die);
	    }
	    else {
		$die->throw_die();
		# DOES NOT RETURN
	    }

	    # Can we find the fields in the Form?
	}

	# If execute_ok returns true, just get out.  The task will
	# stop executing so no need to test errors.
	return 1 if $res;

	if ($fields->{errors}) {
	    _put_file_field_reset_errors($self);
	}
	elsif ( ! $fields->{stay_on_page}) {
	    _redirect($self, 'next');
	    # DOES NOT RETURN
	}
    }
    $self->internal_post_execute('validate_and_execute_ok');

    # Some type of error, rollback and fall through to the next
    # task items.
    my($req) = $self->get_request;
    $req->warn('form_errors=', $fields->{errors}) if $fields->{errors};
    Bivio::Agent::Task->rollback($req) unless $fields->{stay_on_page};
    return 0;
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

Ensures the specified field isn't undef and isn't in error. Puts an error on
the form if it fails.

=cut

sub validate_not_null {
    my($self, $field) = @_;
    my($value) = $self->get($field);

    # Only put the error if not already in error
    $self->internal_put_error($field, Bivio::TypeError::NULL())
	    unless defined($value) || $self->get_field_error($field);
    return;
}

=for html <a name="validate_not_zero"></a>

=head2 validate_not_zero(string field)

Ensures the specified field isn't 0. Puts an error on the form if it fails.

=cut

sub validate_not_zero {
    my($self, $field) = @_;
    my($value) = $self->get($field);
    return unless defined($value);

    $self->internal_put_error($field, Bivio::TypeError::NOT_ZERO())
	    if $value == 0;
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
    $die->throw_die() unless defined($table);
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
    $die->throw_die() unless $got_one;
    return;
}

# _call_execute(self, string method, string args, ...) : any
#
# Calls internal_pre_execute, $method($args, ...), then internal_post_execute.
#
sub _call_execute {
    my($self, $method) = (shift, shift);
    $self->internal_pre_execute($method);
    my($res) = $self->$method(@_);
    $self->internal_post_execute($method);
    return $res;
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
    # return nothing.  We never return the "content" back to the user
    # with FileFields.
    return defined($value->{filename}) ? $value->{filename} : '';
}

# _initial_context(Bivio::Biz::FormModel self, Bivio::Agent::Request req) : hash_ref
#
# If "self" does not have context, does nothing (context is undef).
# Else, initialize the context to the "next" task unless the context
# is passed in from the req.
#
sub _initial_context {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    return unless $fields->{require_context};

    my($c) = $req->unsafe_get('form_context');
    $c = Bivio::Biz::FormContext->empty($self) unless $c;
    _trace('context: ', $c) if $_TRACE;
    return $c;
}

# _parse(Bivio::Biz::FormModel self, hash_ref form) : boolean
#
# Parses the form.
#
# Returns 0 if unwind.
# Returns 1 otherwise
#
sub _parse {
    my($self, $form) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Clear any incoming errors
    delete($fields->{errors});
    my($sql_support) = $self->internal_get_sql_support;
    _trace("form = ", $form) if $_TRACE;
    _parse_version($self,
	    $form->{VERSION_FIELD()},
	    $sql_support);
    # Parse context first
    _parse_context($self, $form) if $fields->{require_context};
    # Ditto for timezone
    _parse_timezone($self, $form->{TIMEZONE_FIELD()});

    # Allow ListFormModel to initialize its state
    $self->internal_pre_parse_columns();

    my($values) = {};
    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);

    # .next is set in _redirect()
    my($next) = $form->{'.next'} || '';
    _redirect($self, 'cancel') if $next eq 'cancel';
    return 0 if $next eq 'unwind';

    return 1;
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
	$n =~ s/^(.*)\.x\=/$1/;
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

	# try one more time in case of image buttons, append '.x' to name
	unless (defined($v) || defined($err)) {
	    ($v, $err) = $self->get_field_info($n, 'type')
		    ->from_literal($form->{$fn.'.x'});
	    $values->{$n} = $v;
	}

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
	    Bivio::IO::Alert->warn('Error in hidden value(s), refreshing: ',
		    {field => $n, actual => $form->{$fn}, error => $err});
	    _redirect_same($self);
	    # DOES NOT RETURN
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

    if ($form->{CONTEXT_FIELD()}) {
	# If there is an incoming context, must be syntactically valid.
	# Overwrites the query context, if any.
	# Note that we don't convert "from_html", because we write the
	# context in Base64 which is HTML compatible.
	$fields->{context} = Bivio::Biz::FormContext->from_literal(
		$self, $form->{CONTEXT_FIELD()});
    }
    else {
	# OK, to not have incoming context unless have it from query
	$fields->{context} = _initial_context($self, $self->get_request)
		unless $fields->{context};
    }
    _trace('context: ', $fields->{context}) if $_TRACE;
    return;
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

    unless ($v =~ /^[+-]?\d+$/) {
	Bivio::IO::Alert->warn($v, ':timezone field in form invalid');
	return;
    }

    my($req) = $self->get_request;
    my($cookie) = $req->get('cookie');
    my($old_v) = $cookie->unsafe_get($_TIMEZONE_COOKIE_FIELD);

    # No change, don't do any more work
    return if defined($old_v) && $old_v eq $v;

    # Set the new timezone
    $cookie->put($_TIMEZONE_COOKIE_FIELD => $v);
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
    $self->throw_die(Bivio::DieCode::VERSION_MISMATCH(),
	    {field => VERSION_FIELD(),
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

# _put_literal(hash_ref fields, string form_name, string value)
#
# Modifies the literal value of the named form field.  In the event
# of a file field, sets filename.
#
sub _put_literal {
    my($fields, $form_name, $value) = @_;
    # If a complex form field has a filename, set it and clear content.
    # We never return the "content" back to the user with FileFields.
    $fields->{literals}->{$form_name}
	    = ref($fields->{literals}->{$form_name})
		    ? {filename => $value} : $value;
    return;
}

# _redirect(Bivio::Biz::FormModel self, string which)
#
# Redirect to the "next" or "cancel" task depending on "which" if there
# is no context.  Otherwise, redirect to context.
#
sub _redirect {
    my($self, $which) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $self->get_request;

    # Ensure this form_model is seen as the redirect model
    # by get_context_from_request and set a flag so it
    # knows to pop context instead of pushing.
    $req->put(form_model => $self);
    $fields->{redirecting} = 1;

    # Success, redirect to the next task or to the task in
    # the context.
    $req->client_redirect($req->get('task')->get($which))
	    # Simulate what happens in client_redirect.  We don't want
	    # context, because there isn't any and we don't want it to
	    # default (would loop back to where we are).
#	    undef, $req->unsafe_get('query'), $req->unsafe_get('path_info'),
#	    1)
	    unless $fields->{context};

    my($c) = $fields->{context};
    unless ($c->{form}) {
	if ($which eq 'cancel' && $c->{cancel_task}) {
	    _trace('no form, client_redirect: ', $c->{cancel_task}) if $_TRACE;
	    # If there is no form, redirect to client so looks
	    # better.  get_context_from_request will do the right thing
	    # and return the stacked context.
	    $req->client_redirect($c->{cancel_task}, $c->{realm},
		   $c->{query}, $c->{path_info});
	    # DOES NOT RETURN
	}

	# Next or cancel (not form)
	_trace('no form, client_redirect: ', $c->{unwind_task},
		'?', $c->{query}) if $_TRACE;
	# If there is no form, redirect to client so looks
	# better.
	$req->client_redirect($c->{unwind_task}, $c->{realm},
		$c->{query}, $c->{path_info});
	# DOES NOT RETURN
    }

    # Do an server redirect to context, because can't do
    # client redirect (no way to pass form state (reasonably)).
    # Indicate to the next form that this is a SUBMIT_UNWIND
    # Make sure you use that form's SUBMIT_UNWIND button.
    # In the cancel case, we chain the cancels.

    # Initializes context
    my($f) = $c->{form};
    $f->{'.next'} = $which eq 'cancel' ? 'cancel' : 'unwind';

    # Redirect calls us back in get_context_from_request
    _trace('have form, server_redirect: ', $c->{unwind_task},
	    '?', $c->{query}) if $_TRACE;
    $req->server_redirect($c->{unwind_task}, $c->{realm},
	    $c->{query}, $f, $c->{path_info});
    # DOES NOT RETURN
}

# _redirect_same(Bivio::Biz::FormModel self)
#
# Redirects to "this" task, because we've encountered a caching
# problem.
#
sub _redirect_same {
    my($self) = @_;
    my($req) = $self->get_request;
    # The form was corrupt.  Throw away the context and
    # the form and redirect back to this task.
    $req->server_redirect($req->get('task_id'),
	    undef, $req->get('query'), undef,
	    $req->get('path_info'));
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
