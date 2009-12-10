# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type;
use strict;
use base 'Bivio::UI::WidgetValueSource';
use Bivio::HTML;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::XML;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
# INITIALIZATION: must be explicit, because Bivio::Base does too much so
# can't use b_use.  This package is very early on in import order.
my($_HTML) = 'Bivio::HTML';
my($_A) = 'Bivio::IO::Alert';
my($_RT);

sub can_be_negative {
    # : boolean
    # Can the number be negative?
    return undef;
}

sub can_be_positive {
    # : boolean
    # Can the number be positive?
    return undef;
}

sub can_be_zero {
    # : boolean
    # Can the number be equal to 0?
    return undef;
}

sub compare {
    # (self, any, any) : int
    # Compares two values and returns the same as perl's
    # C<cmp> operator, namely:
    #
    #
    # negative
    #
    # I<left> is the lesser value.
    #
    # zero
    #
    # I<left> and I<right> are equal.
    #
    # positive
    #
    # I<right> is the lesser value.
    #
    #
    # Treats C<undef> as "least" or equal if both I<left> or I<right>.  Subclasses
    # call this way:
    #
    #     return shift->SUPER::compare(@_)
    # 	unless defined($left) && defined($right);
    my($proto, $left, $right) = @_;
    return 0
	unless defined($left) || defined($right);
    return -1
	unless defined($left);
    return 1
	unless defined($right);
    return shift->compare_defined(@_);
}

sub compare_defined {
    # (proto, any, any) : int
    # Called by L<compare|"compare"> when both values are defined.  Compares the
    # values using C<cmp>.  Results are undefined if either argument is undefined.
    my($proto, $left, $right) = @_;
    return $left cmp $right;
}

sub from_literal {
    # (proto, string) : array
    # (proto, string) : any
    # Validates and converts the value from a literal to an internal form.
    # The literal is usually a compact representation of the value, e.g.
    # for Enums it is the integer form.
    #
    # If the value is valid, the value returned.
    #
    # If the value is NULL, the value C<undef> is returned.  Note that
    # strings return '' as C<undef> in keeping with SQL.
    #
    # If the value is invalid, the array (<C<undef>, I<error>)
    # is returned, where I<error> is one of
    # L<Bivio::TypeError|Bivio::TypeError>.
    #
    # See L<to_literal|"to_literal">.
    shift;
    return shift;
}

sub from_literal_or_die {
    # (proto, string, boolean) : any
    # Checks the return value of L<from_literal|"from_literal">
    # and calls die with an appropriate message if from_literal
    # conversion failed.  Dies with TypeError::NULL if not defined and
    # !I<null_ok>.
    #
    # Returns a scalar, not an array.
    my($proto, $value, $null_ok) = @_;
    my($v, $e) = $proto->from_literal($value);
    return $v
	if defined($v) || $null_ok && !$e;
    $e ||= $proto->use('Bivio::TypeError')->NULL;
    $proto->use('Bivio::Die')->throw_die('DIE', {
	message => 'from_literal failed: ' . $e->get_long_desc,
	program_error => 1,
	error_enum => $e,
	entity => $value,
	class => (ref($proto) || $proto),
    });
}

sub from_sql_column {
    # (self, string) : string
    # Converts I<result>, which is a single column value returned by SELECT, to the
    # perl representation of that type.  I<result> must be generated by
    # L<from_sql_value|"from_sql_value"> for the type.  For enums, will convert to
    # the appropriate enum value.
    shift;
    return shift;
}

sub from_sql_value {
    # (proto, string) : string
    # Converts I<place_holder>, which is typically a column name on a SELECT, to
    # a TO_CHAR string.  For most types, returns I<place_holder>.  For dates,
    # returns the appropiate TO_CHAR for that date type.
    #
    # I<place_holder> will not be quoted.
    #
    # See L<from_sql_column|"from_sql_column">.
    shift;
    return shift;
}

sub get_decimals {
    # : int
    # Number of digits to the right of the decimal point.
    return undef;
}

sub get_instance {
    # (proto, any) : Bivio.Type
    # (self) : Bivio.Type
    # Returns an instance of I<type>.  I<type> may be just the simple name or a fully
    # qualified class name.  It will be loaded with
    # L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader> using the I<Type> map.
    #
    # The "instance" returned may a fully-qualified class, since instances and
    # classes are equivalent in perl.
    my($self, $type) = @_;
    $type ||= $self;
    $type = $self->use('Type', $type)
	unless ref($type);
    $_A->bootstrap_die($type, ': not a Bivio::Type')
	unless UNIVERSAL::isa($type, 'Bivio::Type')
	    || UNIVERSAL::isa($type, 'Bivio::Delegator');
    return $type;
}

sub get_max {
    # : any
    # Maximum value for this type in perl form.  Note that numbers
    # are returned as strings if they are larger than can be handled
    # by perl's integer type.
    return undef;
}

sub get_min {
    # : any
    # Minimal value for this type in perl form.  Note that numbers
    # are returned as strings if they are larger than can be handled
    # by perl's integer type.
    return undef;
}

sub get_precision {
    # : int
    # Maximum number of digits in a value of this type.
    return undef;
}

sub get_width {
    # : int
    # Maximum number of characters for string representations of
    # this value.  If a number cannot be negative, then will
    # not include a character for a sign.
    die('abstract method');
}

sub handle_call_autoload {
    my($proto) = shift;
    return @_ ? $proto->from_literal_or_die(@_) : $proto;
}

sub internal_from_literal_warning {
    # (proto) : undef
    # Issues a warning about calling from_literal() in a scalar context.
    warn("don't call from_literal in scalar context");
    return;
}

sub is_equal {
    # (proto, any, any) : boolean
    # Are the two values equal?  Uses "eq" comparison if compare is not available.
    return shift->compare(@_) == 0 ? 1 : 0;
}

sub is_password {
    # (proto) : boolean
    # Is this value a password, i.e. should it not be displayed?
    #
    # Default is false.
    return 0;
}

sub is_secure_data {
    # (proto) : boolean
    # Requires that the field be displayed only in secure environments.
    #
    # Returns false by default.
    return 0;
}

sub is_specified {
    # (self, any) : boolean
    # Returns true if value is not C<undef>.
    return defined($_[1]) ? 1 : 0;
}

sub is_specified_literal {
    my($proto) = shift;
    return $proto->is_specified(($proto->from_literal(shift))[0]);
}

sub max {
    my($proto, @values) = @_;
    return $proto->iterate_reduce(sub {
        my($v1, $v2) = @_;
	return $proto->compare($v1, $v2) > 0 ? $v1 : $v2;
    }, \@values);
}

sub min {
    my($proto, @values) = @_;
    return $proto->iterate_reduce(sub {
        my($v1, $v2) = @_;
	return $proto->compare($v1, $v2) < 0 ? $v1 : $v2;
    }, \@values);
}

sub put_on_request {
    # (self, Agent.Request, boolean) : self
    # Puts an instance of I<self> on request.  Only works with types which are
    # instantiated.
    my($self, $req, $put_durable) = @_;
    $_A->bootstrap_die($self, ': must be instance')
	unless ref($self);
    my($method) = $put_durable ? 'put_durable' : 'put';
    $req->$method(
	ref($self) => $self,
	'Type.' . $self->simple_package_name => $self,
    );
    return $self;
}

sub row_tag_get {
    my($rt, $proto, $model_or_id) = _row_tag(@_);
    my($v) = $rt->get_value($model_or_id, $proto->ROW_TAG_KEY);
    return $proto->is_specified($v) ? $v : $proto->get_default;
}

sub row_tag_replace {
    my($rt, $proto, $model_or_id, $value) = _row_tag(@_);
    $rt->replace_value(
	$model_or_id,
	$proto->ROW_TAG_KEY,
	!$proto->is_specified($value)
	    || $proto->is_equal($value, $proto->get_default)
	    ? undef
	    : $proto->to_sql_param($value),
    );
    return;
}

sub to_group_by_value {
    return shift->to_order_by_value(@_);
}

sub to_html {
    # (proto, any) : string
    # Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
    # empty string.  Otherwise, escapes html and returns.
    my($self, $value) = @_;
    return '' unless defined($value);
    return $_HTML->escape($self->to_literal($value));
}

sub to_literal {
    # (proto, any) : string
    # Converts from internal form to a literal string value.
    #
    # See L<from_literal|"from_literal">.
    my(undef, $value) = @_;
    return defined($value) ? $value : '';
}

sub to_order_by_value {
    shift;
    return shift;
}

sub to_query {
    # (proto, any) : string
    # Returns a value that can be used as a query string.
    # Similar to L<to_uri|"to_uri">, but
    # calls L<$_HTML::escape_query|$_HTML/"escape_query">
    my($proto, $value) = @_;
    return '' unless defined($value);
    return $_HTML->escape_query($proto->to_literal($value));
}

sub to_sql_param {
    # (proto, string) : string
    # Converts I<param_value>, which is in the perl representation the data type, to
    # a value to a value execute can use.  For most types, simply returns
    # I<param_value>.  For dates, converts the unix time (integer) to the string form
    # acceptable to the type's L<to_sql_value|"to_sql_value">.  For enums, converts
    # the enum to an integer.  For booleans, forces to be 0 or 1.
    my(undef, $value) = @_;
    return defined($value) && length($value) ? $value : undef;
}

sub to_sql_param_list {
    # (proto, array_ref) : array_ref
    # Converts I<param_values> using L<to_sql_param|"to_sql_param">.
    my($proto, $param_values) = @_;
    return [map {$proto->to_sql_param($_)} @$param_values];
}

sub to_sql_value {
    # (proto, string) : string
    # Converts I<place_holder> to an appropriately formed SQL value for the type.
    # Typically, I<place_holder> is a question-mark (?) and the text generated
    # is also a question-mark.  However, for dates, the appropriate
    # C<TO_DATE> call is generated for I<value>.
    #
    # I<place_holder> will not be quoted.
    #
    # See also L<to_sql_param|"to_sql_param">.
    shift;
    return shift || '?';
}

sub to_sql_value_list {
    # (proto, array_ref) : string
    # Creates a parameter string (C<(?,?,?)>) using L<to_sql_value|"to_sql_value">
    # to match the args handled by L<to_sql_param_list|"to_sql_param_list">.
    #
    # Dies if I<param_values> is empty.
    my($proto, $param_values) = @_;
    die('empty param values') unless @$param_values;
    return '('.join(',', map {$proto->to_sql_value('?')} @$param_values).')';
}

sub to_string {
    # (proto, any) : string
    # Returns the L<to_literal|"to_literal"> representation of the value.
    # Always returns a defined value.  I<undef> is returned as the empty string.
    #
    # B<Use for debugging only.>
    my($self, $value) = @_;
    $value = $self->to_literal($value);
    return defined($value) ? $value : '';
}

sub to_uri {
    # (proto, any) : string
    # Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
    # empty string.  Otherwise, escapes uri and returns.
    my($proto, $value) = @_;
    return '' unless defined($value);
    return $_HTML->escape_uri($proto->to_literal($value));
}

sub to_xml {
    return Bivio::XML->escape(shift->to_literal(shift));
}

sub _row_tag {
    # (model, value) - uses primary id from model
    # (id, value, req) - uses id
    # (req, value) - uses auth_id
    my($proto, $model_or_id_or_req) = (shift, shift);
    my($req);
    if (Bivio::Agent::Request->is_blessed($model_or_id_or_req)) {
	$req = $model_or_id_or_req;
	$model_or_id_or_req = $req->get('auth_id');
    }
    else {
	$req = Bivio::Biz::Model->is_blessed($model_or_id_or_req)
	    ? $model_or_id_or_req->req
	    : pop(@_);
    }
    return (
	Bivio::Biz::Model->new($req, 'RowTag'),
	$proto,
	$model_or_id_or_req,
	@_,
    );
}

1;
