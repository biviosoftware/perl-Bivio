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

C<Bivio::Biz::FormModel>

=cut


=head1 CONSTANTS

=cut

=for html <a name="SUBMIT"></a>

=head2 SUBMIT : string

Returns name of submit button.

=cut

sub SUBMIT {
    return 'submit';
}

=for html <a name="SUBMIT_CANCEL"></a>

=head2 SUBMIT_CANCEL : string

Returns Cancel button value

=cut

sub SUBMIT_CANCEL {
    return 'Cancel';
}

=for html <a name="SUBMIT_NEXT"></a>

=head2 SUBMIT_NEXT : string

Returns the Next button value.

=cut

sub SUBMIT_NEXT {
#TODO: not valid HTML, but can't fix now
    return 'Next >>';
}

=for html <a name="SUBMIT_OK"></a>

=head2 SUBMIT_OK : string

Returns OK button value.

=cut

sub SUBMIT_OK {
    return '  OK  ';
}

#=IMPORTS
use Bivio::Agent::Task;
use Bivio::IO::Trace;
use Bivio::SQL::FormSupport;

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

Loads a new instance of this model using the request.
If the form processing ends in errors, any transactions are rolled back.

=cut

sub execute {
    my($proto, $req) = @_;
    my($input) = $req->unsafe_get('form');
    my($self) = $proto->new($req);
#TODO: Bind to "form" too?
#    my($list_model) = $req->unsafe_get('list_model');
    my($list_properties);
#    # If there is a list_model associated with this form, then we have
#    # to make sure it loaded successfully and that there was a "this"
#    # on the query.
#    if ($list_model) {
#	$self->die(Bivio::DieCode::NOT_FOUND(),
#		list_model => $list_model) unless $list_model->next_row;
#	$list_properties = $list_model->internal_get();
#    }
    if ($input) {
	_execute_input($self, $input, $list_properties);
	# Errors occured processing input, rollback
	Bivio::Agent::Task->rollback if $self->{$_PACKAGE}->{errors};
    }
    else {
	_load($self, $list_properties);
    }
    # Render form filled in from db, new form, or form with errors
    $req->put(ref($self) => $self, form_model => $self);
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
    my($sql_support) = $self->internal_get_sql_support();
#TODO: make a constant
    my(@res);
    push(@res, 'version', $sql_support->get('version'));
    my($properties) = $self->internal_get();
    foreach my $col (@{$sql_support->get('hidden')}) {
	push(@res, $col->{form_name},
		$col->{type}->to_literal($properties->{$col->{name}}));
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

Associate I<error> with I<property>.

=cut

sub internal_put_error {
    my($self, $property, $error) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('not a Bivio::TypeError')
		unless UNIVERSAL::isa($error, 'Bivio::TypeError');
    _trace($property, ': ', $error->as_string) if $_TRACE;
    $fields->{errors} = {} unless $fields->{errors};
    $fields->{errors}->{$property} = $error;
    return;
}

#=PRIVATE METHODS

# _execute_input(Bivio::Biz::FormModel self, hash_ref input, hash_ref list_properties)
#
# Parses the input with _parse().  If succesful, checks to see
# list_properties (if exists) against this form's primary_key.  All
# the values should match or someone is trying to stuff data into an
# arbitrary data field by hacking the primary_id of the form.
#
# Finally, call the execute_input method on the class.  This will
# do the work necessary to store the form data.
#
sub _execute_input {
    my($self, $input, $list_properties) = @_;
    my($fields) = $self->{$_PACKAGE};
    # Cancel causes an immediate redirect.  False means there was
    # form input error that the user should correct.  We don't check
    # the list_model unless the form parses correctly.
    _parse($self, $input);
    return if $fields->{errors};
    my($sql_support) = $self->internal_get_sql_support();
    my($properties) = $self->internal_get();
    if ($list_properties) {
#TODO: SECURITY: Is this elegant or a total hack?
	# Validate that the inpu
	foreach my $n ($sql_support->get('primary_key_names')) {
	    next if defined($properties->{$n})
		    && defined($list_properties->{$n})
			    && $properties->{$n} eq $list_properties->{$n};
	    $self->die(Bivio::DieCode::NOT_FOUND,
		    message => 'mismatched list model primary key',
		    field => $n, field_value => $properties->{$n});
	}
	# Form and List are in synch.  Authorized
    }
#TODO: Security fails if no list model.
    my($op) = 'update';
    foreach my $n ($sql_support->get('primary_key_names')) {
	$op = 'create', last unless defined($properties->{$n});
    }
    $self->validate($op eq 'create');
    return if $fields->{errors};
    $self->$op();
    return if $fields->{errors};
    # Success, redirect to the next task.
    my($req) = $self->get_request;
    $req->client_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

# _load(Bivio::Biz::FormModel self, hash_ref list_properties)
#
# If there are list_properties, load them into the form and load any
# other model properties that are missing from this form.
#
sub _load {
    my($self, $list_properties) = @_;
    return unless $list_properties;
#TODO: Is this elegant or a total hack?
    # Copy all identical properties from list model
    my($properties) = {};
    my($sql_support) = $self->internal_get_sql_support();
    my(@missed);
    foreach my $col ($sql_support->get('columns')) {
	my($n) = $col->{name};
	if (exists($list_properties->{$n})) {
	    $properties->{$n} = $list_properties->{$n};
	}
	else {
	    $properties->{$n} = undef;
	    push(@missed, $col);
	}
    }
    # Store the properties so get_model can find them.
    $self->internal_put($properties);

    # Fill in missing properties by trying to load models
    #TODO: On complex traversals, this won't work, because the order in
    #      which the models are loaded.  May want to loop here
    # (
    foreach my $col (@missed) {
	next unless $col->{model};
	my($m) = $self->get_model($col->{model});
	$properties->{$col->{name}} = $m->get($col->{column_name});
    }
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
    # Delete the form, because we don't want other models processing
    # it.  We've handled it already.
    my($sql_support) = $self->internal_get_sql_support;
    $self->get_request->delete('form');
    _trace("form = ", $form) if $_TRACE;
    _parse_version($self, $form->{version}, $sql_support);
    _parse_submit($self, $form->{SUBMIT()});
    my($values) = {};
    _parse_cols($self, $form, $sql_support, $values, 1);
    _parse_cols($self, $form, $sql_support, $values, 0);
    $self->internal_put($values);
    return;
}

# _parse_col(Bivio::Biz::FormModel self, hash_ref form, Bivio::SQL::FormSupport sql_support, hash_ref values, boolean is_hidden)
#
# Parses the form field and returns the value.  Stores errors in the
# fields->{errors}.  Errors in hidden fields
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
	if ($is_hidden) {
	    # Hidden fields must always be defined
	    $err = Bivio::TypeError::NULL() unless $err;
	    $self->die(Bivio::DieCode::CORRUPT_FORM(),
		    {field => $col->{name}, field_error => $err,
			field_value => $form->{$fn}});
	}
	# Null visible field ok?
	unless ($err) {
	    next if $col->{constraint} == Bivio::SQL::Constraint::NONE();
	    $err = Bivio::TypeError::NULL();
	}
	# Error in visible field
	$self->internal_put_error($col->{name}, $err);
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
    $value ||= SUBMIT_OK();

    if ($value eq SUBMIT_CANCEL()) {
	my($req) = $self->get_request;
	# client redirect on cancel
	$req->client_redirect($req->get('task')->get('cancel'));
	# Does not return
    }
    return if $value eq SUBMIT_OK() || $value eq SUBMIT_NEXT();

#TODO: need a general fix for this
    # lynx trims submit padding!
    return if SUBMIT_OK =~ /$value/x;

    $self->die(Bivio::DieCode::CORRUPT_FORM(),
	    {field => SUBMIT(),
		expected => SUBMIT_OK().' or '.SUBMIT_CANCEL()
		.' or '.SUBMIT_NEXT(),
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
