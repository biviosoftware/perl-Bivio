# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::WidgetValueSource;
use strict;
$Bivio::UI::WidgetValueSource::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::WidgetValueSource::VERSION;

=head1 NAME

Bivio::UI::WidgetValueSource - defines get_widget_value interface

=head1 SYNOPSIS

    use Bivio::UI::WidgetValueSource;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::WidgetValueSource::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::WidgetValueSource> defines
L<get_widget_value|"get_widget_value"> interface, which is
used by L<Bivio::UI:Widget|Bivio::UI:Widget> to get its dynamic
values.  Many classes implement this interface, but the main
WidgetValueSources are L<Bivio::Agent::Request|Bivio::Agent::Request>,
L<Bivio::Biz::Model|Bivio::Biz::Model>,
and L<Bivio::UI::FacadeComponent|Bivio::UI::FacadeComponent>.

=head1 EXAMPLES

A I<widget value> is a variable which a Widget uses as a control value or value
to render.  The widget value language is rich, but is unfortunately complex to
describe.  Read L<get_widget_value|"get_widget_value"> for a formal
description.  The following examples help to clarify how they are
used in practice.

    ['uri']

The I<uri> attribute from the WidgetValueSource is returned to the widget
requesting it.  In this case, the WidgetValueSource is probably a Request and
the value is the uri on the request.

    ['auth_user', 'display_name']

Again, a typical Request attribute is requested.  The I<auth_user> is not
a string, but an instance.  We rarely want to display the instance, so
we get its I<display_name> attribute here.

    [['->get_request'], 'auth_user', 'display_name']

A nested widget value is used here to be sure we are retrieving the
I<auth_user> attribute from the Request and not some other WidgetValueSource.
WidgetValueSources implement L<get_request|"get_request"> in various
ways.  You should probably use this second form, because the simple
case (previous example) may net be evaluated in the right context.

    ['RealmOwner.name']

A L<ListModel|Bivio::Biz::ListModel>
or L<FormModel|Bivio::Biz::FormModel> widget value usually
looks something like this. We know this isn't a PropertyModel, because
the name has a '.' in it.  ListModels and FormModels reference fields
in PropertyModels by prefixing field name with the PropertyModel name.

During rendering, the L<Table|Bivio::UI::HTML::Widget::Table> widget changes
its source to the ListModel being iterated.  This allows you to define a widget
value which returns a column's value, i.e. each time the widget value is
evaluated, it returns the field value for each row of a ListModel.

    ['->format_uri', Bivio::Biz::QueryType->THIS_DETAIL,
           Bivio::Agent::TaskId->A_DETAIL_TASK]

A drill down widget value is one which provides an href to
a L<Link|Bivio::UI::HTML::Widget::Link> widget which is embedded
in a L<Table|Bivio::UI::HTML::Widget::Table>.  Here's we'd like
to format a URI for the I<A_DETAIL_TASK>.  The query string will
contain a primary key which tells I<A_DETAIL_TASK> what value to
operate on.

    [sub {
         my($source) = @_;
         return sqrt($source->get('SomeModel.some_value'));
    },

You can insert arbitrary logic into widget values by passing
code references (subroutines).  Alternatively, you could specify
the sub as a formatter, e.g.

    ['SomeModel.some_value', sub {sqrt(shift(@_))}]

The difference between the two cases is subtle.  In the first case,
the first argument is a code_ref and it is executed directly.
The current WidgetValueSource is passed along with any subsequent
arguments (in this case there are none).

In the second case, the sub is a formatter.
I<SomeModel.some_value> is first interpreted by the current
WidgetValueSource and attribute's value is I<formatted> using
the code_ref.  Here's another formatter example.

    ['RealmOwner.creation_date_time',
        'Bivio::UI::HTML::Format::DateTime', 'DATE_TIME'],

The attribute value I<RealmOwner.creation_date_time> is retrieved
and formatted using the
L<DateTime|Bivio::UI::HTML::Format::DateTime> formatter.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Alert;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="get_request"></a>

=head2 get_request() : Bivio::Agent::Request

Returns the current request.  Should be implemented by
subclasses.  Defaults to
L<Bivio::Agent::Request::get_current|Bivio::Agent::Request/"get_current">.

=cut

sub get_request {
    return Bivio::Agent::Request->get_current;
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(any param1, ...) : any

=head2 get_widget_value(any param1, ..., any widget_value_source, ...) : any

Returns a value to be used by a L<Bivio::UI::Widget|Bivio::UI::Widget>.

I<Evaluation> is calling I<get_widget_value> on I<self> recursively.
Any array_ref which is passed as a parameter is subject to evaluation.

I<param1> is processed by this method to get a dynamic I<value> from
I<self>.  The way I<param1> is interpreted is value and type dependent
as follows:

=over 4

=item Not operation (!)

<param1> is the literal string "!" (exclamation point).
The subsequent parameterrs are passed unevaluated to
I<$self-E<gt>get_widget_value>.  The result is logically
negated (not) and a valid Type.Boolean (0 or 1) is returned, i.e.

    return $self->get_widget_value(evaluated-params) ? 1 : 0

=item Named method invocation (-E<gt>method)

I<param1> begins with C<-E<gt>>, the perl method call operator.
C<$self-E<gt>$param1> will be
called with the subsequent parameters after evaluation (see above), i.e.

    return $self->$param1(evaluated-params)

=item Named value lookup (unsafe_get_widget_value_by_name)

I<param1> is a string which is passed to
L<unsafe_get_widget_value_by_name|"unsafe_get_widget_value_by_name">
which is implemented by subclasses, i.e.

    $value = $self->unsafe_get_widget_value_by_name($param1)

Subsequent interpretation of I<$value> is discussed below.

=item Widget value evaluation (array_ref)

I<param1> is an array_ref it is evaluated (see above), i.e.

    $value = $self->get_widget_value(@$param1)

Subsequent interpretation of I<$value> is discussed below.

=item Code invocation (code_ref)

I<param1> is code reference (sub).  I<param1> is passed
$self followed by subsequent, evaluated parameters, i.e.

    return &$param1($self, evaluated-params, $self)

=item Any other type/value

Dies if I<param1> is another type, e.g. hash_ref or blessed reference.

=back

I<$value> and subsequent parameters go through a first phase of
post processing as follows:

=over 4

=item No more params (only $param1)

I<$value> is returned verbatim if I<param1> is the only argument.

=item Blessed reference (get_widget_value)

I<$value> is a blessed reference in which case it's get_widget_value
will be called.  Dies if I<$value> does not implement get_widget_value.
I.e.

     return $value->get_widget_value(evaluated-parameters)

=item array_ref

I<$value> is an array_ref.  The subsequent, evaluated parameter (param2)
is used to index $value.  The indexed value I<replaces> $value.  Only
one level of indexing is allowed and the indexed value must be defined.
I.e.

     $value = $value->[evaluated-param2]

=item hash_ref

I<$value> is an hash_ref.  The subsequent, evaluated parameter (param2)
is used to index $value.  The indexed value I<replaces> $value.  Only
one level of indexing is allowed and the indexed value must be defined.
I.e.

     $value = $value->{evaluated-param2}

=item scalar

I<$value> is a scalar.  Processing continues below.

=item Any other type/value

Dies if I<$value> is another type, e.g. code_ref.

=back

The second phase of post processing of I<$value> and subsequent parameters
is defined below:

=over 4

=item No more params (only param1)

If there are no more parameters, I<$value> is returned verbatim.

=item Blessed reference formatter (ref)

The next parameter is evaluated and must return a reference or
class which implements I<get_widget_value>.  I<$value> is passed
to the formatter followed by the subsequent, evaluated parameters, i.e.

    return $param2->get_widget_value($value, evaluated-params)

=item Class reference formatter (string)

The same as blessed reference, but the class will be loaded
by L<Bivio::IO::ClassLoader::map_require|Bivio::IO::ClassLoader/"map_require">
first.

=item Subroutine formatter (code_ref)

I<$param2> is a code_ref.  I<$value> is passed
to the formatter followed by the subsequent, evaluated parameters, i.e.

    return $param2->get_widget_value($value, evaluated-params)

=back

See the L<EXAMPLES|"EXAMPLES"> section.

=cut

sub get_widget_value {
    my($self) = shift;
    _trace('params=', \@_) if $_TRACE;
    _die($self, 'too few arguments passed to ', $self) unless @_;
    my($param1) = shift;
    my($value, $exists);

    unless (ref($param1)) {
	# "Not" operation?
	return $self->get_widget_value(@_) ? 0 : 1 if $param1 eq '!';

	# If first arg begins with '->', then is a method to call.
	# Evaluate the rest of the arguments in this context.
	return $self->$param1(_eval_args($self, @_))
		if $param1 =~ s/^\-\>//;

	# Try to get by name after special names have been exhausted
	($value, $exists) = $self->unsafe_get_widget_value_by_name($param1);
    }

    unless ($exists) {
	if (UNIVERSAL::can($param1, 'get_widget_value')) {
	    # Have to have params to call get_widget_value
	    return $param1->get_widget_value(_eval_args($self, @_)) if @_;

	    # Otherwise, couldn't find it.
	    _die($self, $param1, ': not found in WidgetValueSource ', $self);
	}

	if (ref($param1) eq 'ARRAY') {
	    $value = $self->get_widget_value(@$param1);
	    # We fall through
	}
	elsif (ref($param1) eq 'CODE') {
	    return &$param1($self, _eval_args($self, @_));
	}
	else {
	    _die($self, $param1, ": not found and can't get_widget_value");
	}
    }

    # Anything more to evaluate?
    return $value unless @_;

    # Have value figure out what to do with it
    unless (ref($value)) {
	# fall through, not a reference.  Next param is formatter (see below)
    }
    elsif ($value =~ /=/) {
	# It's a blessed reference, must support get_widget_value
	return $value->get_widget_value(_eval_args($self, @_));
    }
    else {
	# value is not a blessed reference (array_ref, hash_ref, etc.)
	my($param2) = shift;
	_die($self, $param1, ': is a ref, but not passed second param')
		    unless defined($param2);
	# Evaluate index if an array_ref
	$param2 = $self->get_widget_value(@$param2)
		if ref($param2) eq 'ARRAY';
	if (ref($value) eq 'HASH') {
	    # key must exist
	    _die($self, $param1, '->{', $param2, '}: does not exist')
			unless exists($value->{$param2});
	    $value = ($value->{$param2});
	}
	elsif (ref($value) eq 'ARRAY') {
	    # index must exist (and be a number)
	    _die($self, $param1, '->[', $param2, ']: does not exist')
			unless $param2 <= $#$value;
	    $value = $value->[$param2];
	}
	else {
	    _die($self, $param1, ': unsupported reference type: ',
		    ref($value));
	}
    }

    # Anything more to evaluate?
    return $value unless @_;

    # Check for next param which must be able to get_widget_value or
    # must be a widget value which returns something that can return
    # a widget value.
    my($param2) = shift(@_);
    return &$param2($value, _eval_args($self, @_)) if ref($param2) eq 'CODE';

    $param2 = $self->get_widget_value(@$param2) if ref($param2) eq 'ARRAY';
    unless (UNIVERSAL::can($param2, 'get_widget_value')) {
	my($tmp) = Bivio::IO::ClassLoader->map_require($param2);
	_die($self, $tmp, ": can't get_widget_value (not a formatter)")
		unless UNIVERSAL::can($tmp, 'get_widget_value');
	$param2 = $tmp;
    }
    return $param2->get_widget_value($value, _eval_args($self, @_))
}

=for html <a name="unsafe_get_widget_value_by_name"></a>

=head2 unsafe_get_widget_value_by_name(string name) : array

Returns (I<value>, I<exists>) for the value from I<self> for I<name>.
If doesn't exist, I<exists> will be false and I<value> should be C<undef>.

Default implementation is deprecated form.

=cut

sub unsafe_get_widget_value_by_name {
    my($self, $name) = @_;
    Bivio::IO::Alert->warn_deprecated('first argument must begin with ->');
    return ($self->$name(), 1);
}

#=PRIVATE METHODS

# _die(self, any msg, ...)
#
# Terminates with nice message
#
sub _die {
    my($self, @msg) = @_;
    my($sub) = (caller(1))[3];
    $sub =~ s/.*://;
    Bivio::IO::Alert->bootstrap_die($self, '->', $sub, ': ', @msg);
    # DOES NOT RETURN
}

# _eval_args(self, string arg1, ...) : array
#
# Returns the arguments evaluated as widget values if they are
# array_ref.
#
sub _eval_args {
    my($self) = shift;
    return map {
	ref($_) eq 'ARRAY' ? $self->get_widget_value(@$_) : $_;
    } @_;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
