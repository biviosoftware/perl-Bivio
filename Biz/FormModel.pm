# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::FormModel;
use strict;
use Bivio::Base 'Biz.Model';
use Bivio::Agent::HTTP::Cookie;
use Bivio::Agent::Task;
use Bivio::Biz::FormContext;
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::Trace;
use Bivio::SQL::FormSupport;

# C<Bivio::Biz::FormModel> is the business logic behind HTML forms.  A FormModel
# has fields like other models.  Fields are either I<visible> or
# I<hidden>.  A FormModel may have a primary_key which is useful to know
# how to load the form values from the database.
#
# If there is a form associated with the request, the individual fields are
# validated and then the form-specific L<validate|"validate"> method is
# called to do cross-field validation.
#
# If the validation passes, i.e. no errors are put with
# L<internal_put_error|"internal_put_error">, then
# L<execute_ok|"execute_ok"> is called.
#
# A form may have a context.  This is specified by the C<require_context> in
# L<internal_initialize_sql_support|"internal_initialize_sql_support">, or on
# the task as I<require_context> or I<want_workflow>.  The
# context is how we got to this form, e.g. from another form and the contents of
# that form.  Forms with context return to the uri specified in the context on
# "ok" completion.  If the request has FormModel.require_context set to false,
# no context will be required.  If the task has require_context set to false
# and this is the primary form (Task.form_model), no context will be required.
# If the context exists and is I<want_workflow>, we'll accept the context.
#
# A query may have a context as well.  The form's context overrides
# the query's context.  The query's context is usually only valid
# for empty forms.
#
# If the context contains a form, it may be manipulated with
# L<unsafe_get_context_field|"unsafe_get_context_field"> and
# L<put_context_fields|"put_context_fields">.
# For example, a symbol lookup form might set the symbol selected
# in the form which requested the lookup.
#
# If a form is executed as a the result of a server redirect
# and L<SUBMIT_UNWIND|"SUBMIT_UNWIND"> is set,
# no data transforms will occur and the form will render literally
# as it was entered before.  User gets a new opportunity to OK or
# CANCEL.
#
# The only tight connection to HTML is the way submit buttons are rendered.
# The problem is that the value of a submit type field is the text that
# appears in the button.  This means what the user sees is what we get
# back.  The routines L<SUBMIT|"SUBMIT">, L<SUBMIT_OK|"SUBMIT_OK">, and
# L<SUBMIT_CANCEL|"SUBMIT_CANCEL"> can be overridden by subclasses if
# they would like different text to appear.
#
# Form field errors are always one of the enums in
# L<Bivio::TypeError|Bivio::TypeError>.
#
# Free text input widgets (Text and TextArea) retrieve field values with
# L<get_field_as_html|"get_field_as_html">, because the field may be in error
# and the errant literal value may not be valid for the type.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
Bivio::Agent::HTTP::Cookie->register(__PACKAGE__);

sub CONTEXT_FIELD {
    return 'c';
}

sub GLOBAL_ERROR_FIELD {
    return '_';
}

sub MAX_FIELD_SIZE {
    # To avoid tossing around huge chunks of invalid data, we have an maximum
    # size of a field for non-FileField values.
    #
    # I<Subclasses may override this method and should if they expect
    # huge fields, e.g. mail message bodies.>
    return 0x10000;
}

sub NEXT_FIELD {
    return '.next';
}

sub OK_BUTTON_NAME {
    return 'ok_button';
}

sub TIMEZONE_FIELD {
    return 'tz';
}

sub VERSION_FIELD {
    return 'v';
}

sub clear_errors {
    my($fields) = shift->[$_IDI];
    _trace($fields->{errors}, ' ', $fields->{error_details}) if $_TRACE;
    delete($fields->{errors});
    delete($fields->{error_details});
    return;
}

sub create_model_properties {
    return _do_model_properties(create => @_);
}

sub create_or_update_model_properties {
    return _do_model_properties(create_or_update => @_);
}

sub execute {
    my($proto, $req, $values) = @_;
    # There are two modes:
    #
    # html form
    #
    # I<values> is not passed.  Form values are processed from I<req.form>.
    # Loads a new instance of this model using the request.
    # If the form processing ends in errors, any transactions are rolled back.
    #
    # The value I<form_model> is "put" on I<req> in this case only.
    #
    # action
    #
    # This method is called as an action with I<values>.  I<values>
    # passed must match the properties of this FormModel.  If an error
    # occurs parsing the form, I<die> is called--internal program error
    # due to incorrect parameter passing.  On success, this method
    # returns normally.  This method should only be used if the caller
    # knows I<values> is valid.   L<validate|"validate"> is not called.
    return $proto->new($req)->process($values);
}

sub execute_cancel {
    my($self, $button_field) = @_;
    # Default cancel processing, redirects to the cancel task.
    # client redirect on cancel, no state is saved
    _redirect($self, 'cancel');
    # DOES NOT RETURN
}

sub execute_empty {
    # Processes an empty form.  By default is a no-op.
    #
    # B<Return true if you want the Form to execute immediately>
    return 0;
}

sub execute_ok {
    # Processes the form after validation.  By default is an no-op.
    #
    # Return true if you want the Form to exit immediately.
    # Return a Bivio::Agent::TaskId, if you want to change next.
    return 0;
}

sub execute_other {
    # Processes the form after a cancel or other button is pressed.
    # The button string is passed.  It will redirect to the cancel
    # task for the form.
    #
    # Although it is unlikely, you'll ever want to do this.
    # Return true if you want the Form to execute immediately.
    return 0;
}

sub execute_unwind {
    # Called in the L<SUBMIT_UNWIND|"SUBMIT_UNWIND"> case.  The form
    # is already parsed, but not validated.  You cannot assume any
    # fields are valid.
    #
    # This method is called right before L<execute|"execute"> is
    # about to return.  You can modify fields with
    # L<internal_put_field|"internal_put_field">.
    #
    # Although it is unlikely, you'll ever want to do this.
    # Return true if you want the Form to execute immediately.
    return 0;
}

sub format_context_as_query {
    my(undef, $fc, $req) = @_;
    # B<Only to be called by Bivio::UI::Task.>
    #
    # Takes context (which may be null), and formats as query string.
    return $fc ? '?fc=' . Bivio::HTML->escape_query($fc->as_literal($req)) : '';
}

sub get_context_from_request {
    my(undef, $named, $req) = @_;
    # Extract the context from C<req.form_model> depending on various state params.
    # If I<named.no_form> is true, we don't add in the form to the context.  This is
    # used by L<format_context_as_query|"format_context_as_query"> to limit the size.
    #
    # Does not modify I<named>.
    my($self) = $req->unsafe_get('form_model');
    # If there is a model, make sure not redirecting
    my($form, $context);
    if ($self) {
	my($fields) = $self->[$_IDI];
	if ($fields->{redirecting}) {
	    # Just in case, clear the sentinel
	    $fields->{redirecting} = 0;
	    if ($req->unsafe_get_nested(qw(task want_workflow))) {
		_trace('kept context for workflow: ', $fields->{context})
		    if $_TRACE;
		return $fields->{context};
	    }
	    # If redirecting, return the stacked context if there is one
	    my($c) = $fields->{context};
	    $c &&= $c->get('form_context');
	    _trace('unwound context: ', $c) if $_TRACE;
	    return $c;
	}
	$form = $self->internal_get_field_values;
	$context = $self->[$_IDI]->{context};
	_trace('model from request: ', $form) if $_TRACE;
    }
    elsif ($self = $req->get('task')->get('form_model')) {
	$self = $self->get_instance;
	$form = $req->unsafe_get('form');
	_trace('model from task: ', $form) if $_TRACE;
    }

    $context = $form = undef
	if $named->{no_form};
    $context = undef
        if $named->{no_context};

    # Fix up file fields if any
    my($ff);
    if ($form && $self && ($ff = $self->internal_get_file_field_names)) {
	# Need to copy, because we don't want to trash existing form.
	my($f) = {%$form};
	foreach my $n (@$ff) {
	    my($fn) = $self->get_field_name_for_html($n);
	    # Converts to just the file name.  We'd never get this back,
	    # but we can stuff it into the form.  Widget::File
	    # knows how to handle this.
	    $f->{$fn} = $self->get_field_info($n, 'type')
		->to_literal($f->{$fn});
	    _trace($n, ': set value=', $f->{$fn}) if $_TRACE;
	}
	$form = $f;
    }
    return Bivio::Biz::FormContext->new_from_form($self, $form, $context, $req);
}

sub get_errors {
    return shift->[$_IDI]->{errors};
}

sub get_error_details {
    return shift->[$_IDI]->{error_details};
}

sub get_field_as_html {
    my($self, $name) = @_;
    my($fields) = $self->[$_IDI];
    my($value) = $self->unsafe_get($name);
    return $self->get_field_info($name, 'type')->to_html($value)
	    if defined($value);
    my($fn) = $self->get_field_name_for_html($name);
    return Bivio::HTML->escape(_get_literal($fields, $fn));
}

sub get_field_as_literal {
    my($self, $name) = @_;
    my($fields) = $self->[$_IDI];
    my($value) = $self->unsafe_get($name);
    return $self->get_field_info($name, 'type')->to_literal($value)
	    if defined($value);
    return _get_literal($fields, $self->get_field_name_for_html($name));
}

sub get_field_error {
    my($self, $name) = @_;
    my($e) = $self->get_errors;
    return $e ? $e->{$name} : undef;
}

sub get_field_error_detail {
    my($self, $name) = @_;
    my($fields) = $self->[$_IDI];
    return ($fields->{error_details} || {})->{$name};
}

sub get_field_name_for_html {
    return shift->get_field_info(shift, 'form_name');
}

sub get_hidden_field_values {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($sql_support) = $self->internal_get_sql_support;
    return [
        $self->VERSION_FIELD => $sql_support->get('version'),
        $fields->{context} ? (
	    $self->CONTEXT_FIELD =>
		$fields->{context}->as_literal($self->get_request),
	) : (),
	map((
	    $self->get_field_name_for_html($_),
	    $self->get_field_as_literal($_),
	), @{$self->internal_get_hidden_field_names}),
    ];
}

sub get_literals_copy {
    # Does not copy file fields
    return {%{shift->internal_get_literals}};
}

sub get_model_properties {
    my($self, $model) = @_;
    # Returns the properties for this model that were passed in with the form.
    $model = $model->simple_package_name()
	if ref($model);
    my($sql_support) = $self->internal_get_sql_support();
    my($properties) = $self->internal_get();
    my($models) = $sql_support->get('models');
    Bivio::Die->die($model, ': no such model')
	unless defined($models->{$model});
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

sub get_stay_on_page {
    # Returns state of L<internal_stay_on_page|"internal_stay_on_page">.
    # May not be set
    return shift->[$_IDI]->{stay_on_page} ? 1 : 0;
}

sub get_visible_non_button_names {
    my($self) = @_;
    return [sort(
	grep(!$self->get_field_type($_)->isa('Bivio::Type::FormButton'),
	     @{$self->internal_get_visible_field_names}),
    )];
}

sub handle_cookie_in {
    my($self, $cookie, $req) = @_;
    # Looks for timezone in I<cookie> and sets I<timezone> on I<req>.
    my($v) = $cookie->unsafe_get($self->TIMEZONE_FIELD);
    $req->put_durable(timezone => $v) if defined($v);
    return;
}

sub has_context_field {
    my($self, $name) = @_;
    # Returns true if there is a form in the context and it has a context
    # field I<name>.
    my($fields) = $self->[$_IDI];
    return 0 unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->unsafe_get('form_model');
    return $model ? $model->get_instance->has_fields($name) : 0
}

sub in_error {
    # Returns true if any of the form fields are in error.
    return shift->get_errors ? 1 : 0;
}

sub internal_catch_field_constraint_error {
    my($self, $field, $op, $info_field) = @_;
    # Executes I<op> and catches a die.  If the die is a I<DB_CONSTRAINT>, applies
    # resultant I<type_error> to I<field>, and returns true.
    #
    # If I<info_field> is supplied, additional error information from the die is
    # appended to that field.
    #
    # Returns false if I<op> executes without dying.
    my($die) = Bivio::Die->catch($op);
    return 0
	unless $die;
    $die->throw
	unless $die->get('code')->equals_by_name('DB_CONSTRAINT')
	    && UNIVERSAL::isa($die->get('attrs')->{type_error},
		'Bivio::TypeError');
    my($attrs) = $die->get('attrs');
    $self->internal_put_error($field, $attrs->{type_error});
    $self->internal_put_field($info_field =>
        join("\n", $self->get($info_field), $attrs->{error_info}))
	  if $info_field && exists($attrs->{error_info});

    return 1;
}

sub internal_clear_error {
    my($self, $property) = @_;
    # Clears the error on I<property> if any.
    #
    # If I<property> is null, clears the "form" error.
    return unless $self->in_error;
    $property ||= $self->GLOBAL_ERROR_FIELD;
    my($e) = $self->get_errors;
    delete($e->{$property});
    $self->clear_errors
	unless %$e;
    return;
}

sub internal_clear_literal {
    my($self, $property) = @_;
    # Clears I<property>'s literal value.
    my($fields) = $self->[$_IDI];
    _put_literal($fields, $self->get_field_name_for_html($property), '');
    return;
}

sub internal_field_constraint_error {
    # This method is called when a DB constraint is encountered during the
    # form's execution.
    #
    # The default action is a no-op.  The error is already "put" on the
    # field.
    return;
}

sub internal_get_field_values {
    my($self) = @_;
    # Returns the form as literals
    my($fields) = $self->[$_IDI];
    my($properties) = $self->internal_get;
    my($res) = {
	$self->VERSION_FIELD => $self->get_info('version'),
	$self->TIMEZONE_FIELD => $fields->{literals}->{$self->TIMEZONE_FIELD},
    };
    foreach my $n (@{$self->internal_get_hidden_field_names},
	   @{$self->internal_get_visible_field_names}) {
	$res->{$self->get_field_name_for_html($n)}
		= $self->get_field_as_literal($n);
    }
    return $res;
}

sub internal_get_file_field_names {
    # B<Used internally to this module and ListFormModel.>
    #
    # Returns I<file_field_names> attribute.
    return shift->internal_get_sql_support()->unsafe_get('file_field_names');
}

sub internal_get_hidden_field_names {
    # B<Used internally to this module and ListFormModel.>
    #
    # Returns I<hidden_field_names> attribute.
    return shift->get_info('hidden_field_names');
}

sub internal_get_literals {
    # B<Used internally to this module and ListFormModel.>
    #
    # Returns the literals hash_ref.
    return shift->[$_IDI]->{literals};
}

sub internal_get_visible_field_names {
    # B<Used internally to this module and ListFormModel.>
    #
    # Returns I<visible_field_names> attribute.
    return shift->get_info('visible_field_names');
}

sub internal_initialize {
    # B<FOR INTERNAL USE ONLY>
    return {
	visible => [
	    {
		name => shift->OK_BUTTON_NAME,
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

sub internal_initialize_sql_support {
    my($proto, $stmt, $config) = @_;
    # Returns the L<Bivio::SQL::FormSupport|Bivio::SQL::FormSupport>
    # for this class.  Calls L<internal_initialize|"internal_initialize">
    # to get the hash_ref to initialize the sql support instance.
    die('cannot create anonymous PropertyModels') if $config;
    $config = $proto->internal_initialize;
    $config->{class} = ref($proto) || $proto;
    return Bivio::SQL::FormSupport->new($config);
}

sub internal_parse {
    my($self, $fields) = @_;
    # Run field validation.  Useful for forms that want to show errors
    # automatically on execute_empty

    my($values) = $self->internal_get;
    _parse($self, $fields || $self->internal_get_field_values());
    # need to restore previous values because _parse() will remove invalid ones
    # for example, if the secondary email is invalid
    $self->internal_put($values);
    $self->validate
	unless $self->in_error;
    return;
}

sub internal_post_execute {
    # Called to initialize info I<after> a validate_and_execute_ok, execute_empty,
    # execute_unwind, execute_other, or execute_cancel.
    #
    # This routine must be robust against data errors and the like.
    # I<method> is which method was just invoked, if the method did not
    # end in an exception (including redirects).
    #
    # Does nothing by default.
    #
    # See also L<internal_pre_execute|"internal_pre_execute">.
    return;
}

sub internal_pre_execute {
    # Called to initialize info before a validate_and_execute_ok, execute_empty,
    # execute_unwind, execute_other, or execute_cancel.
    #
    # This routine must be robust against data errors and the like.
    # I<method> is which method that is about to be invoked.
    #
    # Does nothing by default.
    #
    # See also L<internal_post_execute|"internal_post_execute">.
    return;
}

sub internal_pre_parse_columns {
    # B<Used internally to this module and ListFormModel.>
    #
    # Called just before C<_parse_cols> is called, so C<ListFormModel> can
    # initialize its list_model to determine number of rows to expect.
    return;
}

sub internal_put_error {
    return shift->internal_put_error_and_detail(shift, shift);
}

sub internal_put_error_and_detail {
    my($self, $property, $error, $detail) = @_;
    my($fields) = $self->[$_IDI];
    $error = Bivio::TypeError->from_any($error);
    $property ||= $self->GLOBAL_ERROR_FIELD;
    ($fields->{errors} ||= {})->{$property} = $error;
    ($fields->{error_details} ||= {})->{$property} = $detail;
    # Details don't have types.  They are application specific.
    _trace($property, ': ', $error, defined($detail) ? ('; ', $detail) : ())
	if $_TRACE;
    return;
}

sub internal_put_field {
    my($self, $property, $value) = @_;
    # Puts a value on a field.  No validation checking.
    $self->internal_get->{$property} = $value;
    return;
}

sub internal_redirect_next {
    my($self) = @_;
    # Redirects to the next form task. This can be used to double unwind
    # a form context, popping another level when called from
    # L<execute_unwind|"execute_unwind">.
    _redirect($self, 'next');
    return;
}

sub internal_stay_on_page {
    my($self) = @_;
    # Directs the form to remain on the current page regardless of the error state.
    # Any changes are committed to the database. This is useful for non-submit
    # buttons which need to perform calculations on the current data.
    my($fields) = $self->[$_IDI];
    $fields->{stay_on_page} = 1;
    return;
}

sub is_auxiliary_on_task {
    my($self) = @_;
    my($c) = $self->req(qw(task form_model));
    return 0
	if defined($c) && $c eq ref($self);
    _trace(ref($self), ': auxiliary form; primary_class=', $c)
	if $_TRACE;
    return 1;
}

sub is_field_editable {
    # Returns true if the field is editable. By default all fields are editable,
    # subclasses may override this to provide this value dynamically.
    return 1;
}

sub load_from_model_properties {
    my($self, $model) = @_;
    # Gets I<model> and copies all properties from I<model> to I<properties>.
    # If I<model> is not a reference, calls L<get_model|"get_model"> first.
    my($sql_support) = $self->internal_get_sql_support();
    my($models) = $sql_support->get('models');
    my($m);
    if (ref($model)) {
	$m = $model;
	$model = $m->simple_package_name;
    }
    else {
	$m = $self->get_model($model);
    }
    $self->die($model, ': no such model')
        unless defined($models->{$model});
    my($column_aliases) = $sql_support->get('column_aliases');
    foreach my $cn (@{$models->{$model}->{column_names_referenced}}) {
#TODO: Document this is being used elsewhere!
	my($pn) = $column_aliases->{$model.'.'.$cn}->{name};
	# Copy the model's property to this model
        $self->internal_put_field($pn => $m->get($cn));
    }
    return;
}

sub merge_initialize_info {
    my($proto, $parent, $child) = @_;
    # Merges two model field definitions (I<child> into I<parent>) into a new
    # hash_ref.
    my($names) = {};
    foreach my $i ($child, $parent) {
	foreach my $class (qw(visible other hidden)) {
	    foreach my $name (@{$i->{$class} || []}) {
		my($v) = ref($name) eq 'HASH' ? $name
		    : ref($name) eq 'ARRAY' ? {
			name => $name->[0],
			_aliases => [@$name[1..$#$name]],
		    } : {name => $name};
		$v->{_class} = $class;
		foreach my $attr (keys(%$v)) {
		    my($x) = ($names->{$v->{name}} ||= {});
		    $x->{$attr} = $v->{$attr}
			unless exists($x->{$attr});
		}
	    }
	    delete($i->{$class});
	}
    }
    # Sort so works with testing
    foreach my $v (sort {$a->{name} cmp $b->{name}} values(%$names)) {
	push(
	    @{$child->{delete($v->{_class})} ||= []},
	    $v->{_aliases} ? [
		delete($v->{name}),
		@{delete($v->{_aliases})},
		%$v ? Bivio::Die->die('cannot equivalence a hash') : (),
	    ] : keys(%$v) == 1 ? $v->{name} : $v,
	);
    }
    return $proto->SUPER::merge_initialize_info($parent, $child);
}

sub new {
    return shift->SUPER::new(@_)->reset_instance_state;
}

sub process {
    my($self, $req, $values) = @_;
    # Does the work for L<execute|"execute"> after execute creates a I<self>.
    if (ref($req) eq 'HASH') {
	$values = $req;
	$req = undef;
    }
    $req ||= $self->get_request;
    my($fields) = $self->[$_IDI];

    # Save in request
    $self->put_on_request;

    # Called as an action internally, process values.  Do no validation.
    if ($values) {
	$self->internal_pre_parse_columns;
	$self->internal_put($values);
	$fields->{literals} = {};
	# Forms called internally don't have a context.  Form models
	# should blow up.

	$self->internal_pre_execute('execute_ok');
	my($res) = _call_execute_ok($self, $self->OK_BUTTON_NAME);
	$self->internal_post_execute('execute_ok');
	return $res if $res;
	return 0 unless $self->in_error;
	if ($_TRACE) {
	    my($msg) = '';
	    my($e) = $self->get_errors;
	    foreach my $field (keys(%$e)) {
		$msg .= $field.' '.$e->{$field}->get_name."\n";
	    }
	    _trace($msg);
	}
	Bivio::Die->die(
	    $self,
	    ': called with invalid values, ',
	    $self->get_errors,
	    ' ',
	    $self->get_error_details || '',
	    ' ',
	    $self->internal_get,
	);
	# DOES NOT RETURN
    }
    if ($self->is_auxiliary_on_task) {
	$fields->{want_context} = $self->get_info('require_context');
	# Auxiliary forms are not the "main" form models on the page
	# and therefore, do not have any input.  They always return
	# back to this page, if they require_context.
	$fields->{literals} = {};
	$fields->{context} = $self->get_context_from_request({}, $req)
	    if $fields->{want_context};
	return _call_execute($self, 'execute_empty');
    }
    $fields->{want_context} = $self->get_info('require_context')
	&& $self->req(qw(task require_context));
    _trace(
	ref($self), ': primary form, want_context=', $fields->{want_context}
    ) if $_TRACE;

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
	$fields->{context} = Bivio::Biz::FormContext->new_from_literal(
	    $self, $query->{fc});
	# We don't want it to appear in any more URIs now that we can
	# store it in a form.
	delete($query->{fc});
	$req->put(query => undef)
	    unless %$query;
	_trace('context: ', $fields->{context}) if $_TRACE;
    }

    # User didn't input anything, render blank form
    unless ($input) {
	$fields->{literals} = {};
	$fields->{context} = _initial_context($self)
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
    my($button, $button_type) = ($self->OK_BUTTON_NAME,
				 'Bivio::Type::OKButton');
    foreach my $field (@{$self->get_keys}) {
	if (defined($self->get($field))) {
	    my($type) = $self->get_field_type($field);
	    ($button, $button_type) = ($field, $type)
		    if $type->isa('Bivio::Type::FormButton');
	}
    }
    return $self->validate_and_execute_ok($button)
	if $button_type->isa('Bivio::Type::OKButton');
    return _call_execute($self, 'execute_cancel', $button)
	if $button_type->isa('Bivio::Type::CancelButton');
    return _call_execute($self, 'execute_other', $button);
}

sub put_context_fields {
    my($self) = shift;
    # Allows you to put multiple context fields on this form's context.
    #
    # B<Does not work for I<in_list> ListForm fields unless you specify
    # the field name explicitly, e.g. RealmOwner.name.1>.
    # Allow zero fields (see _redirect)
    $self->die('must be an even number of parameters')
	unless @_ % 2 == 0;
    my($fields) = $self->[$_IDI];
    $self->die('form does not have context')
	unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->get('form_model');
    $self->die('context does not contain form_model')
	unless $model;

    my($mi) = $model->get_instance;
    # If there is no form, initialize
    my($f) = $c->get_if_exists_else_put(form => sub {
	return {$self->VERSION_FIELD => $mi->get_info('version')};
    });
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	my($fn) = $mi->get_field_name_for_html($k);
	# Convert with to_literal--context->{form} is in raw form
	$f->{$fn} = $mi->get_field_info($k, 'type')->to_literal($v);
    }
    _trace('new form: ', $c->get('form')) if $_TRACE;
    return;
}

sub reset_instance_state {
    my($self) = @_;
    $self->[$_IDI] = {
	empty_properties => $self->internal_get,
	stay_on_page => 0,
    };
    return $self;
}

sub unauth_create_or_update_model_properties {
    return _do_model_properties(unauth_create_or_update => @_);
}

sub unsafe_get_context {
    # Returns the context object for this form.
    return shift->[$_IDI]->{context};
}

sub unsafe_get_context_field {
    my($self, $name) = @_;
    # Returns the value of the context field.  Result is the same as
    # L<Bivio::Type::from_literal|Bivio::Type/"from_literal">.
    #
    # Note: this is a heavy operation, because it converts the form value
    # each time.
    my($fields) = $self->[$_IDI];
    die('form does not have context')
	unless $fields->{context};
    my($c) = $fields->{context};
    my($model) = $c->get('form_model');
    return undef
	unless $model;
    return undef
	unless $c->get('form');
    # From the form_model's sql_support, get the type and return
    # the result of from_literal.
    my($mi) = $model->get_instance;
    my($type) = $mi->get_field_info($name, 'type');
    my($fn) = $mi->get_field_name_for_html($name);
    return $type->from_literal($c->get('form')->{$fn});
}

sub update_model_properties {
    return _do_model_properties(update => @_);
}

sub validate {
    # By default this method does nothing. Subclasses should override it to provide
    # form specific validation. I<form_button> is the name of the button clicked.
    #
    # C<validate> is always called, even if some of the fields do not
    # meet the SQL constraints.  This allows us to return as many errors
    # as possible to the user.
    #
    # B<Care must be taken when checking fields, because they may be undef.>
    # In general, fields should not be checked by C<validate> if they are
    # C<undef>.
    return;
}

sub validate_and_execute_ok {
    my($self, $form_button) = @_;
    # Validates the form, calling L<validate|"validate">, then executes
    # it, catching any exceptions and adding them to errors. Rolls back
    # changes on errors.
    my($req) = $self->get_request;
    my($fields) = $self->[$_IDI];

    # If the form has errors, the transaction will be rolled back.
    # validate is always called so we try to return as many errors
    # to the user as possible.
    $self->internal_pre_execute('validate_and_execute_ok');
    $self->validate($form_button);
    if ($self->in_error) {
	_put_file_field_reset_errors($self);
    }
    else {
	# Catch errors and rethrow unless we can process
	my($res) = _call_execute_ok($self, $form_button);
	Bivio::Biz::Action->get_instance('Acknowledgement')->save_label(
	    undef,
	    $req,
	    ref($res) eq 'HASH' && exists($res->{query})
		? ($res->{query} ||= {}) : (),
	) unless $self->in_error || $fields->{stay_on_page};

	# If execute_ok returns true, just get out.  The task will
	# stop executing so no need to test errors.
	return $res if $res;

	if ($self->in_error) {
	    _put_file_field_reset_errors($self);
	}
	elsif ( ! $fields->{stay_on_page}) {
	    $self->internal_redirect_next;
	    # During unit tests, will fall through
	    return 0;
	}
    }
    $self->internal_post_execute('validate_and_execute_ok');
    $req->warn('form_errors=', $self->get_errors, ' ', $self->get_error_details)
	if $self->in_error;
    unless ($fields->{stay_on_page}) {
	Bivio::Agent::Task->rollback($req);
	if (my $t  = $req->get('task')->unsafe_get('form_error_task')) {
	    $self->put_on_request(1);
	    return {
		method => 'server_redirect',
		task_id => $t,
		map(($_ => $req->unsafe_get($_)), qw(
		    query
		    path_info
		)),
	    };
	}
    }
    return 0;
}

sub validate_greater_than_zero {
    # Ensures the specified field is greater than 0. Puts an error on the form
    # if it fails.  Returns false if the field is in error or if an error is
    # put on the field. An undef value is valid.
    return _validate(1, sub {shift(@_) <= 0 && 'GREATER_THAN_ZERO'}, @_);
}

sub validate_not_negative {
    # Ensures the specified field isn't negative. Puts an error on the form
    # if it fails. Returns false if the field is in error or if an error is
    # put on the field. An undef value is valid.
    return _validate(1, sub {shift(@_) < 0 && 'NOT_NEGATIVE'}, @_);
}

sub validate_not_null {
    # Ensures the specified field isn't undef and isn't in error. Puts an error on
    # the form if it fails.  Returns false if the field is in error or if an error is
    # put on the field.
    return _validate(0, sub {!defined(shift(@_)) && 'NULL'}, @_);
}

sub validate_not_zero {
    # Ensures the specified field isn't 0. Puts an error on the form if it fails.
    # Returns false if the field is in error or if an error is
    # put on the field. An undef value is valid.
    return _validate(1, sub {shift(@_) == 0 && 'NOT_ZERO'}, @_);
}

sub _apply_type_error {
    my($self, $die) = @_;
    # Looks up the columns and table in this form model.  If found,
    # applies the errors to the form model.
    my($attrs) = $die->get('attrs');
    _trace($attrs) if $_TRACE;
    my($err) = $attrs->{type_error};
    Bivio::Die->die($err, ': die type_error not a Bivio::TypeError')
	unless ref($err) && UNIVERSAL::isa($err, 'Bivio::TypeError');
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

sub _call_execute {
    my($self, $method) = (shift, shift);
    # Calls internal_pre_execute, $method($args, ...), then internal_post_execute.
    $self->internal_pre_execute($method);
    my($res) = $self->$method(@_);
    $self->internal_post_execute($method);
    return $res;
}

sub _call_execute_ok {
    my($self, $form_button) = @_;
    # Calls "execute_ok" without wrappers, and catches any DB_CONSTRAINT
    # violations.
    my($res);
    my($die) = Bivio::Die->catch(sub {
        $res = $self->execute_ok($form_button);
	return;
    });
    if ($die) {
	if ($die->get('code') == Bivio::DieCode->DB_CONSTRAINT) {
	    # Type errors are "normal"
	    _apply_type_error($self, $die);
	}
	else {
	    $die->throw_die();
	    # DOES NOT RETURN
	}
    }
    return $res;
}

sub _do_model_properties {
    my($method, $self, $model, $override_values) = @_;
    my($get_model) = $method eq 'update' ? 'get_model' : 'new_other';
    return (ref($model) ? $model : $self->$get_model($model))->$method({
	%{$self->get_model_properties(
	    ref($model) ? $model->simple_package_name : $model
	)},
	$override_values ? %$override_values : (),
    });
}

sub _get_literal {
    my($fields, $form_name) = @_;
    # Returns the literal value of the named form field.  Special care
    # is taken to return only the filename attribute of complex form fields.
    my($value) = $fields->{literals}->{$form_name};
    return '' unless defined($value);
    return $value unless ref($value);

    # If a complex form field has a filename, return it.  Otherwise,
    # return nothing.  We never return the "content" back to the user
    # with FileFields.
    return defined($value->{filename}) ? $value->{filename} : '';
}

sub _initial_context {
    my($self) = @_;
    # Return a context if available from the request.  If there is not context,
    # creates one if the form or task wants it.
    my($fields) = $self->[$_IDI];
    my($req) = $self->get_request;
    return $req->unsafe_get('form_context')
	|| ($fields->{want_context}
	   || $req->unsafe_get_nested(qw(task want_workflow))
	       ? Bivio::Biz::FormContext->new_empty($self) : undef);
}

sub _parse {
    my($self, $form) = @_;
    # Parses the form.
    #
    # Returns 0 if unwind.
    # Returns 1 otherwise
    my($fields) = $self->[$_IDI];
    # Clear any incoming errors
    $self->clear_errors;
    my($sql_support) = $self->internal_get_sql_support;
    _trace("form = ", $form) if $_TRACE;
    _parse_version($self,
	    $form->{$self->VERSION_FIELD},
	    $sql_support);
    # Parse context first
    _parse_context($self, $form);
    # Ditto for timezone
    _parse_timezone($self, $form->{$self->TIMEZONE_FIELD});

    # Allow ListFormModel to initialize its state
    $self->internal_pre_parse_columns();

    my($values) = {};
    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);

    # .next is set in _redirect()
    my($next) = $form->{$self->NEXT_FIELD} || '';
    _redirect($self, 'cancel')
	if $next eq 'cancel';
    return 0 if $next eq 'unwind';

    return 1;
}

sub _parse_cols {
    my($self, $form, $sql_support, $values, $is_hidden) = @_;
    # Parses the form field and returns the value.  Stores errors in the
    # fields->{errors}.
    my($fields) = $self->[$_IDI];
    my($method) = $is_hidden ? 'internal_get_hidden_field_names'
	    : 'internal_get_visible_field_names';
    my($null_set) = {};
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
		if (length(${$fv->{content}}) > $self->MAX_FIELD_SIZE) {
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
		&& length($form->{$fn}) > $self->MAX_FIELD_SIZE) {
	    $self->internal_put_error($n, 'TOO_LONG');
	    next;
	}

	# Finally, parse the value
	my($type) = $self->get_field_info($n, 'type');
	my($v, $err) = $type->from_literal($form->{$fn});
	$values->{$n} = $v;

	# try one more time in case of image buttons, append '.x' to name
	unless (defined($v) || defined($err)) {
	    ($v, $err) = $type->from_literal($form->{$fn.'.x'});
	    $values->{$n} = $v;
	}

	# NOT_NULL_SET
	# May need to include NOT_ZERO_ENUM and UNSPECIFIED checks
	# from Success? case below
	if (
	    $self->get_field_info($n, 'constraint')
		== Bivio::SQL::Constraint->NOT_NULL_SET
	) {
	    my($primary_field) =
		$self->get_field_info($n, 'null_set_primary_field');
	    $primary_field .= $1
		if $n =~ /(_\d+)$/;
	    $null_set->{$primary_field} ||= {passed_flag => 0};
	    next
		if $null_set->{$primary_field}->{passed_flag};
	    if (defined($v)) {
		$null_set->{$primary_field}->{passed_flag} = 1;
		$self->internal_clear_error($primary_field);
	    }
	    else {
		$self->internal_put_error($primary_field,
		    Bivio::TypeError->NULL);
		next;
	    }
	}

	# Success?
	if (defined($v)) {
	    # Zero field ok?
	    next unless $self->get_field_info($n, 'constraint')
		== Bivio::SQL::Constraint->NOT_ZERO_ENUM;
	    next if $type->is_specified($v);
	    $err = Bivio::TypeError->UNSPECIFIED;
	}

	# Null field ok?
	unless ($err) {
	    next if $self->get_field_info($n, 'constraint')
		    == Bivio::SQL::Constraint->NONE;
	    $err = Bivio::TypeError->NULL;
	}

	# Error in field.  Save the original value.
	if ($is_hidden) {
	    Bivio::IO::Alert->warn(
		'Error in hidden value(s), refreshing: ',
		{field => $n, actual => $form->{$fn}, error => $err},
	    );
	    _redirect_same($self);
	    # DOES NOT RETURN
	}
	else {
	    $self->internal_put_error($n, $err);
	}
    }
    return;
}

sub _parse_context {
    my($self, $form) = @_;
    # Parses the form's context.  If there is no context, creates it only
    # if !want_workflow.
    my($fields) = $self->[$_IDI];
    $fields->{context} = $form->{$self->CONTEXT_FIELD}
	# If there is an incoming context, must be syntactically valid.
	# Overwrites the query context, if any.
	# Note that we don't convert "from_html", because we write the
	# context in Base64 which is HTML compatible.
	? Bivio::Biz::FormContext->new_from_literal(
	    $self, $form->{$self->CONTEXT_FIELD})
	# OK, to not have incoming context unless have it from query
	: $fields->{context} || _initial_context($self);
    _trace('context: ', $fields->{context}) if $_TRACE;
    return;
}

sub _parse_timezone {
    my($self, $value) = @_;
    # If it is set, will set in cookie.  Otherwise, not set in cookie.

    # Parse the integer
    my($v) = Bivio::Type::Integer->from_literal($value);
    # Only go on if could parse.   Otherwise, other modules know how
    # to handle timezone as undef.
    return unless defined($v);

    unless ($v =~ /^[+-]?\d+$/) {
	Bivio::IO::Alert->warn($v, ': timezone field in form invalid');
	return;
    }

    my($req) = $self->get_request;
    my($cookie) = $req->get('cookie');
    my($old_v) = $cookie->unsafe_get($self->TIMEZONE_FIELD);

    # No change, don't do any more work
    return if defined($old_v) && $old_v eq $v;

    # Set the new timezone
    $cookie->put($self->TIMEZONE_FIELD => $v);
    $req->put_durable(timezone => $v);
    return;
}

sub _parse_version {
    my($self, $value, $sql_support) = @_;
    # Parse the version number.  Throws VERSION_MISMATCH on error.
    if (defined($value)) {
	my($v) = Bivio::Type::Integer->from_literal($value);
	return if (defined($v) && $v eq $sql_support->get('version'));
    }
    $self->throw_die('VERSION_MISMATCH', {
        field => $self->VERSION_FIELD,
        expected => $sql_support->get('version'),
        actual => $value,
        entity => $self->get_request->get('r')
            ? $self->get_request->get('r')->as_string
            : undef,
        content => $self->get_request->get_content
    });
    return;
}

sub _put_file_field_reset_errors {
    my($self) = @_;
    # Puts FILE_FIELD_RESET_FOR_SECURITY on file fields not in error.
    # If there were errors, provide feedback to the user about
    # file fields which are special.
    my($file_fields) = $self->internal_get_file_field_names;
    return unless $file_fields;

    my($fields) = $self->[$_IDI];
    my($properties) = $self->internal_get;
    foreach my $n (@$file_fields) {
	# Don't replace an existing error
	next unless defined($properties->{$n}) && !$self->get_field_error($n);

	# Tells user that we didn't clear the field, the browser did.
	$self->internal_put_error($n,
		Bivio::TypeError->FILE_FIELD_RESET_FOR_SECURITY)
    }
    return;
}

sub _put_literal {
    my($fields, $form_name, $value) = @_;
    # Modifies the literal value of the named form field.  In the event
    # of a file field, sets filename.
    # If a complex form field has a filename, set it and clear content.
    # We never return the "content" back to the user with FileFields.
    $fields->{literals}->{$form_name}
	    = ref($fields->{literals}->{$form_name})
		    ? {filename => $value} : $value;
    return;
}

sub _redirect {
    my($self, $which) = @_;
    # Redirect to the "next" or "cancel" task depending on "which" if there
    # is no context.  Otherwise, redirect to context.
    my($fields) = $self->[$_IDI];
    my($req) = $self->get_request;
    $req->put(form_model => $self);
    $fields->{redirecting} = 1;
    if ($fields->{context}) {
	if ($req->unsafe_get_nested(qw(task want_workflow))) {
	    _trace('continue workflow') if $_TRACE;
	    $req->server_redirect({
		task_id => $req->get('task')->get($which),
		require_context => 1,
	    });
	}
	$fields->{context}->return_redirect($self, $which);
    }
    $req->client_redirect($req->get('task')->get($which));
    # DOES NOT RETURN
}

sub _redirect_same {
    my($self) = @_;
    # Redirects to "this" task, because we've encountered a caching (hidden fields)
    # problem.
    my($req) = $self->get_request;
    # The form was corrupt.  Throw away the context and
    # the form and redirect back to this task.
    $req->server_redirect($req->get('task_id'),
	undef, $req->get('query'), undef, $req->get('path_info'));
    # DOES NOT RETURN
}

sub _validate {
    my($undef_ok, $op, $self, $field) = @_;
    return 0
	if $self->get_field_error($field);
    return 1
        if $undef_ok && ! defined($self->unsafe_get($field));
    return 1
	unless my $e = $op->($self->unsafe_get($field));
    $self->internal_put_error($field, $e);
    return 0;
}

1;
