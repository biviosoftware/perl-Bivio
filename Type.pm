# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type;
use strict;
$Bivio::Type::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::VERSION;

=head1 NAME

Bivio::Type - base class for all types

=head1 SYNOPSIS

    use Bivio::Type;

=cut

use Bivio::UNIVERSAL;
@Bivio::Type::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Type> base class of all types.

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::HTML;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Can the number be negative?

=cut

sub can_be_negative {
    return undef;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Can the number be positive?

=cut

sub can_be_positive {
    return undef;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Can the number be equal to 0?

=cut

sub can_be_zero {
    return undef;
}

=for html <a name="compare"></a>

=head2 abstract static compare(any left, any right) : int

Compares two values and returns the same as perl's
C<cmp> operator, namely:

=over 4

=item negative

I<left> is the lesser value.

=item zero

I<left> and I<right> are equal.

=item positive

I<right> is the lesser value.

=back

=cut

$_ = <<'}'; # emacs
sub compare {
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

=head2 static from_literal(string value) : any

Validates and converts the value from a literal to an internal form.
The literal is usually a compact representation of the value, e.g.
for Enums it is the integer form.

If the value is valid, the value returned.

If the value is NULL, the value C<undef> is returned.  Note that
strings return '' as C<undef> in keeping with SQL.

If the value is invalid, the array (<C<undef>, I<error>)
is returned, where I<error> is one of
L<Bivio::TypeError|Bivio::TypeError>.

See L<to_literal|"to_literal">.

=cut

sub from_literal {
    shift;
    return shift;
}

=for html <a name="from_literal_or_die"></a>

=head2 static from_literal_or_die(string value) : any

Checks the return value of L<from_literal|"from_literal">
and calls die with an appropriate message if from_literal
conversion failed.  Dies with TypeError::NULL if not defined.

Returns a scalar, not an array.

=cut

sub from_literal_or_die {
    my($proto, $value) = @_;
    my($v, $e) = $proto->from_literal($value);
    return $v if defined($v);
    $e ||= Bivio::TypeError::NULL();
    Bivio::Die->throw_die('DIE', {
	message => 'from_literal failed: '.$e->get_long_desc,
	program_error => 1,
	error_enum => $e,
	entity => $value,
	class => (ref($proto) || $proto),
    });
}

=for html <a name="from_sql_column"></a>

=head2 from_sql_column(string result) : string

Converts I<result>, which is a single column value returned by SELECT, to the
perl representation of that type.  I<result> must be generated by
L<from_sql_value|"from_sql_value"> for the type.  For enums, will convert to
the appropriate enum value.

=cut

sub from_sql_column {
    shift;
    return shift;
}

=for html <a name="from_sql_value"></a>

=head2 static from_sql_value(string place_holder) : string

Converts I<place_holder>, which is typically a column name on a SELECT, to
a TO_CHAR string.  For most types, returns I<place_holder>.  For dates,
returns the appropiate TO_CHAR for that date type.

I<place_holder> will not be quoted.

See L<from_sql_column|"from_sql_column">.

=cut

sub from_sql_value {
    shift;
    return shift;
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Number of digits to the right of the decimal point.

=cut

sub get_decimals {
    return undef;
}

=for html <a name="get_instance"></a>

=head2 static get_instance(any type) : Bivio::Type

Returns an instance for I<type>.  This may be a class name.
Will look up names in C<Bivio::Type::> if I<type> is not a reference.

=cut

sub get_instance {
    my($self, $type) = @_;
    unless (ref($type)) {
	$type = 'Bivio::Type::'.$type unless $type =~ /::/;
	Bivio::IO::ClassLoader->simple_require($type);
    }
    Bivio::IO::Alert->die($type, ': not a Bivio::Type')
		unless UNIVERSAL::isa($type, 'Bivio::Type');
    return $type;
}

=for html <a name="get_max"></a>

=head2 static get_max : any

Maximum value for this type in perl form.  Note that numbers
are returned as strings if they are larger than can be handled
by perl's integer type.

=cut

sub get_max {
    return undef;
}

=for html <a name="get_min"></a>

=head2 static get_min : any

Minimal value for this type in perl form.  Note that numbers
are returned as strings if they are larger than can be handled
by perl's integer type.


=cut

sub get_min {
    return undef;
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Maximum number of digits in a value of this type.

=cut

sub get_precision {
    return undef;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Maximum number of characters for string representations of
this value.  If a number cannot be negative, then will
not include a character for a sign.

=cut

sub get_width {
    die('abstract method');
}

=for html <a name="is_equal"></a>

=head2 static is_equal(any left, any right) : boolean

Are the two values equal?  Uses "eq" comparison.  undefs are not
equal, paralleling what happens is SQL.

=cut

sub is_equal {
    my(undef, $left, $right) = @_;
    return 0 unless defined($left) && defined($right);
    return $left eq $right ? 1 : 0;
}

=for html <a name="is_password"></a>

=head2 static is_password() : boolean

Is this value a password, i.e. should it not be displayed?

Default is false.

=cut

sub is_password {
    return 0;
}

=for html <a name="is_secure_data"></a>

=head2 static is_secure_data() : boolean

Requires that the field be displayed only in secure environments.

Returns false by default.

=cut

sub is_secure_data {
    return 0;
}

=for html <a name="to_html"></a>

=head2 static to_html(any value) : string

Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
empty string.  Otherwise, escapes html and returns.

=cut

sub to_html {
    my($self, $value) = @_;
    return '' unless defined($value);
    return Bivio::HTML->escape($self->to_literal($value));
}

=for html <a name="to_literal"></a>

=head2 static to_literal(any value) : string

Converts from internal form to a literal string value.

See L<from_literal|"from_literal">.

=cut

sub to_literal {
    shift;
    return shift;
}

=for html <a name="to_query"></a>

=head2 static to_query(any value) : string

Returns a value that can be used as a query string.
Similar to L<to_uri|"to_uri">, but
calls L<Bivio::HTML::escape_query|Bivio::HTML/"escape_query">

=cut

sub to_query {
    my($proto, $value) = @_;
    return '' unless defined($value);
    return Bivio::HTML->escape_query($proto->to_literal($value));
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(string param_value) : string

Converts I<param_value>, which is in the perl representation the data type, to
a value to a value execute can use.  For most types, simply returns
I<param_value>.  For dates, converts the unix time (integer) to the string form
acceptable to the type's L<to_sql_value|"to_sql_value">.  For enums, converts
the enum to an integer.  For booleans, forces to be 0 or 1.

=cut

sub to_sql_param {
    shift;
    return shift;
}

=for html <a name="to_sql_value"></a>

=head2 static to_sql_value(string place_holder) : string

Converts I<place_holder> to an appropriately formed SQL value for the type.
Typically, I<place_holder> is a question-mark (?) and the text generated
is also a question-mark.  However, for dates, the appropriate
C<TO_DATE> call is generated for I<value>.

I<place_holder> will not be quoted.

See also L<to_sql_param|"to_sql_param">.

=cut

sub to_sql_value {
    shift;
    return shift;
}

=for html <a name="to_string"></a>

=head2 static to_string(any value) : string

Returns the L<to_literal|"to_literal"> representation of the value.
Always returns a defined value.  I<undef> is returned as the empty string.

=cut

sub to_string {
    my($self, $value) = @_;
    $value = $self->to_literal($value);
    return defined($value) ? $value : '';
}

=for html <a name="to_uri"></a>

=head2 static to_uri(any value) : string

Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
empty string.  Otherwise, escapes uri and returns.

=cut

sub to_uri {
    my($proto, $value) = @_;
    return '' unless defined($value);
    return Bivio::HTML->escape_uri($proto->to_literal($value));
}

=for html <a name="to_xml"></a>

=head2 static to_xml(any value) : string

Same as L<to_html|"to_html">.

=cut

sub to_xml {
    return shift->to_html(@_);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
