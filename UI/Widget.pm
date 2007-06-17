# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget;
use strict;
$Bivio::UI::Widget::VERSION = sprintf('d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::VERSION;

=head1 NAME

Bivio::UI::Widget - a renderable object

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::UI::Widget::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::UI::Widget> is the superclass of all UI widgets.  Widgets are
a way of rendering arbitrary strings.  There are few constraints
placed on what a widget can render.  There are three main methods:

=over 4

=item new

=item initialize


=item render

converts attributes and values into the target format.  Currently, this can be
html, gif, pdf, or javascript.  Widget values are retrieved from a I<source>
via the call I<get_widget_value>.  This is the only method that a I<source>
needs to provide to the widget.  The interface is defined in
L<Bivio::UI::WidgetValueSource|Bivio::UI::WidgetValueSource>.

=back

=head2 Attributes

There are different kinds of attributes:

=over 4

=item required

must be supplied to the widget.  If not, initialization fails.

=item inherited

is retrieved along the widget's ancestral lines.
L<Bivio::Collection::Attributes::ancestral_get|Bivio::Collection::Attributes/"ancestral_get">
will search the I<parent> attribute recursively until if finds
a value.

=item default

need not be supplied.  If not supplied, the default value will
be used.  Defaulted attributes are indicated with square brackets []
to the right of the type.

=item dynamic

are retrieved during rendering.  They must be supplied during
initialization, but the value may be change before each call to
render.  See
L<Bivio::UI::Widget::Indirect::value|Bivio::UI::Widget::Indirect/"item_value">
for an example.

=back

An attribute is declared in the I<ATTRIBUTES> section of the Widget.
The items define the name, the type, default value, and the kind
it is (required, inherited, etc.).

=head2 Widget Values

Most widgets have an attribute called C<value>.  Some widgets have
several values.  A widget value may be static, but it typically
is dynamic.  It is a little script which is represented syntactically
as an array_ref.  Here are some of attributes which are expecting
widget values:

    value => ['mailhost'],
    cells => [
	['RealmOwner.name'],
	['RealmUser.role', '->get_short_desc'],
    ],
    source => ['Bivio::Biz::Model::ClubUserList'],
    alt => ['auth_user', 'name', 'Bivio::UI::HTML::Format::Printf',
    		'The auth_user is %s'],

When a Widget's render method is called, it executes the following call:

    $source->get_widget_value(@{$self->get('value')});

The contents of the I<value> attribute in this case is known to
be a widget value.  Let's say I<value> contains the array_ref:

    ['mailhost'],

The string C<'mailhost'> is be passed to C<get_widget_value> of
C<$source>.  Typically, C<$source> is a
L<Bivio::Agent::Request|Bivio::Agent::Request> which must have
a C<mailhost> attribute or the I<get_widget_value> will fail.

Several routines support implicit C<get_widget_value> calls.
For example,
L<Bivio::Agent::Request::format_uri|Bivio::Agent::Request/"format_uri">
will either accept string arguments or array_refs.  If an
array_ref is supplied, C<format_uri> calls C<get_widget_value>
on C<$self> (the request) with the contents of the array_ref
to get the value to be used for its parameter.

The important thing is to think of widget values as "variables"
to a Widget.  This is how Widget behaviour is controlled
dynamically.

=head2 Formatters

There are several types of formatters.  Their C<get_widget_value>
implementations all take
a value as their first argument and configuration parameters
as their subsequent parameters.  They format the value according
to the configuration parameters.

=head2 Request

Some widgets assume there is a request.  While it might make
sense to have dynamic binding through widget values, there is
a well-known call

    $source->get_request

which always returns the request being processed.
It makes sense to avoid clutter in the configuration and
instead assume there is a request for those widgets that need it.
An example is
L<Bivio::UI::HTML::Widget::TextTabMenu|Bivio::UI::HTML::Widget::TextTabMenu>
which needs to know the current task (to highlight it in the
menu) and whether all tasks are executable by the current
I<auth_user>.

In general, widgets get all their values via
C<get_widget_value>.

=head1 ATTRIBUTES

=over 4

=item parent : Bivio::UI::Widget []

This widget's "owner".  The ancestral hierarchy is checked
for attributes, i.e. attributes are inherited from parents.
See
L<Bivio::Collection::Attributes::ancestral_get|Bivio::Collection::Attributes/"ancestral_get">.

=back

=cut


#=IMPORTS
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Widget

=head2 static new(hash_ref attrs) : Bivio::UI::Widget

Creates a new instance and binds the initial attributes.  Instantation is
passive as far as the widgets are concerned, i.e.  attribute binding is the
only action that occurs.

=head2 static new(any arg, ...) : Bivio::UI::Widget

Same as other two versions, but L<internal_new_args|"internal_new_args">
is called to get the hash_ref to pass to
L<Bivio::Collection::Attributes|Bivio::Collection::Attributes>.

=cut

sub new {
    return shift->SUPER::new({})
	if int(@_) == 1;
    return shift->SUPER::new(@_)
	if ref($_[1]) eq 'HASH';
    # Handles weird case where undef is passed to mean "no value"
    return shift->SUPER::new(@_)
	if int(@_) == 2 && !defined($_[1]);
    my($proto) = shift;
    Bivio::Die->die($proto, '->new: only accepts a hash_ref argument')
	unless $proto->can('internal_new_args');
    my($res) = $proto->internal_new_args(@_);
    Bivio::Die->die($proto, '->new: ', $res)
	unless ref($res) eq 'HASH';
    return $proto->SUPER::new($res);
}

=head1 METHODS

=cut

=for html <a name="accepts_attribute"></a>

=head2 static accepts_attribute(string attr) : boolean

Does the widget accept this attribute?

Returns false for backward compatibility.

=cut

sub accepts_attribute {
    return 0;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Renders a terse description of the widget.

=cut

sub as_string {
    my($self) = @_;
    return $self->simple_package_name unless ref($self);

    # Don't recurse more than two levels in calls to this sub.  We
    # look back an arbitrary number of levels (10), because there's
    # nesting inside Alert->format_args.
    my($this_sub) = (caller(0))[3];
    my($recursion) = 0;
    for (my($i) = 1; $i < 20; $i++) {
	my($sub) = (caller($i))[3];
	last unless $sub;
	# Stop at two levels
	return $self->simple_package_name
		if $this_sub eq $sub && ++$recursion >= 1;
    }

    # Can't use join, because it formats the strings incorrectly.
    my(@cfg) = map {($_, ',')} $self->internal_as_string;
    pop(@cfg);

    my($res) = Bivio::IO::Alert->format_args(
	    $self->simple_package_name, @cfg ? ('[', @cfg, ']') : ());
    chomp($res);
    return $res;
}

=for html <a name="die"></a>

=head2 die(string entity, any source, string msg, ...)

Dies with I<msg> and context including I<attr_name> and I<source>
which both may be C<undef>.

=cut

sub die {
    my($self, $entity, $source, @msg) = @_;
    Bivio::Die->throw('DIE', {
	message => Bivio::IO::Alert->format_args(@msg),
	entity => $entity,
	widget => $self,
	view => Bivio::IO::ClassLoader->was_required('Bivio::View')
	    && Bivio::View->unsafe_get_current,
	source => $source,
	program_error => 1,
    });
    # DOES NOT RETURN
}

=for html <a name="get_content_type"></a>

=head2 abstract execute(Bivio::Agent::Request req)

Renders the widget and puts the result on I<req>'s reply.  Only "top level"
widgets are executable,
e.g. L<Bivio::UI::HTML::Widget::Page|Bivio::UI::HTML::Widget::Page>.

Typically, an executable widget will call
L<execute_with_content_type|"execute_with_content_type">.

=cut

$_ = <<'}'; # for emacs
sub execute {
}

=for html <a name="execute_with_content_type"></a>

=head2 execute_with_content_type(Bivio::Agent::Request req, string content_type)

Executable widgets will call this method, which calls L<render|"render">
and sets the reply's output_type to I<content_type>.

=cut

sub execute_with_content_type {
    my($self, $req, $content_type) = @_;
    my($buffer) = '';
    my($reply) = $req->get('reply');
    $self->render($req, \$buffer);
    $reply->set_output_type($content_type);
    $reply->set_output(\$buffer);
    return;
}

=for html <a name="handle_die"></a>

=head2 static handle_die(Bivio::Die die)

Add self to widget_stack.

=cut

sub handle_die {
    my($proto, $die) = @_;
    push(@{$die->get('attrs')->{widget_stack} ||= []}, $proto);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes the widgets internal structures.  Widgets should cache static
attributes.  A Widget's initialize should be callable more than once.

Parses the attributes into an internal format which may result in the
creation of new widgets.  Attributes should not be modified by the
caller after initialization unless they are explicitly labeled
I<dynamic>.

By default, does nothing.

=cut

sub initialize {
    return;
}

=for html <a name="initialize_attr"></a>

=head2 initialize_attr(string attr_name, any default_value) : any

Calls L<unsafe_initialize_attr|"unsafe_initialize_attr">.
Dies if I<attr_name> doesn't exist or is C<undef> and there is no
I<default_value>.

Returns attribute value.

=cut

sub initialize_attr {
    my($self, $attr_name, $default_value) = @_;
    $self->put_unless_exists($attr_name => $default_value)
	if defined($default_value);
    my($res) = $self->unsafe_initialize_attr($attr_name);
    $self->die($attr_name, undef, 'attribute must be defined')
	unless defined($res);
    return $res;
}

=for html <a name="initialize_value"></a>

=head2 initialize_value(string attr_name, any value) : any

Initializes an attribute I<value>.  If I<value> is a widget, will
put I<parent> on I<value> to be I<self>.

I<attr_name> is used only for debugging.

Returns value.

=cut

sub initialize_value {
    my($self, $attr_name, $value) = @_;
    return $value unless defined($value);
    return $value unless UNIVERSAL::isa($value, __PACKAGE__);
    return $value->put_and_initialize(parent => $self);
}

=for html <a name="internal_as_string"></a>

=head2 internal_as_string() : array

Returns a list of values to be joined which describe this widgets
configuration.  You should limit the configuration list to one or
at most two items.

Looks for I<field> or I<value> attributes.

=cut

sub internal_as_string {
    my($self) = @_;
    foreach my $a (qw(field value)) {
	my($v) = $self->unsafe_get($a);
	return ($v) if defined($v);
    }
    return ();
}

=for html <a name="internal_new_args"></a>

=head2 abstract static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">, e.g.

    If(['auth_user'], String(Join(['Hi ', ['auth_user', 'display_name']))))

Subclasses define this method if they accept something other than a hash_ref or
nothing as arguments to new.  See for example
L<Bivio::UI::Widget::Director|Bivio::UI::Widget::Director>
or L<Bivio::UI::Join|Bivio::UI::Join>.

Traditionally, L<new|"new"> accepts a hash_ref as the last argument to new.
This allows arbitrary parameters to be passed.

Must return a hash_ref if succesful.  Otherwise, returns a string
or array_ref which contains the error.

=cut

$_ = <<'}'; # emacs
sub internal_new_args {
}

=for html <a name="put_and_initialize"></a>

=head2 put_and_initialize(string name, any value, ...) : Bivio::UI::Widget

Puts the attributes and initializes.  Typically used in the form:

    $fields->{my_child} = $self->get('some_widget')->put_and_initialize(
           parent => $self,
    );

Returns I<self>.

=cut

sub put_and_initialize {
    my($self) = shift;
    $self->put(@_);
    # Protects against multiple initializations
    $self->put_unless_exists(_initialized => sub {
        $self->initialize;
	return 1;
    });
    return $self;
}

=for html <a name="render"></a>

=head2 abstract render(any source, string_ref buffer)

Appends the value of the widget to I<buffer>.  I<source> is used
to retrieve widget values, if any.  Widgets should not depend that
I<source> is a Request.  Always call:

      my($req) = $source->get_request;

to get the request object.

=cut

$_ = <<'}'; # for emacs
sub render {
}

=for html <a name="render_attr"></a>

=head2 render_attr(string attr_name, any source) : string_ref

=head2 render_attr(string attr_name, any source, string_ref buffer) : string_ref

Calls L<unsafe_render_attr|"unsafe_render_attr">.

Dies if there was no attribute or is C<undef>.

Returns I<buffer>.  If I<buffer> is I<undef>, will create one.

=cut

sub render_attr {
    my($self, $attr_name, $source, $buffer) = @_;
    my($b) = '';
    $buffer = \$b unless $buffer;
    $self->die($attr_name, $source, 'attribute renders as undef')
	unless $self->unsafe_render_attr($attr_name, $source, $buffer);
    return $buffer;
}

=for html <a name="render_simple_attr"></a>

=head2 render_simple_attr(string attr_name, any source) : string

Calls L<unsafe_render_value|"unsafe_render_value">, and returns a
zero length string, never C<undef>, even $attr_name doesn't exist.

=cut

sub render_simple_attr {
    my($self, $attr_name, $source) = @_;
    my($b) = '';
    $self->unsafe_render_attr($attr_name, $source, \$b);
    return $b;
}

=for html <a name="render_simple_value"></a>

=head2 render_simple_value(any value, any source) : string

Calls L<unsafe_render_value|"unsafe_render_value">, and returns a
zero length string, never C<undef>, even $value is empty.

=cut

sub render_simple_value {
    my($self, $value, $source) = @_;
    my($b) = '';
    $self->unsafe_render_value('<anon>', $value, $source, \$b);
    return $b;
}

=for html <a name="render_value"></a>

=head2 render_value(string attr_name, any value, any source, string_ref buffer) : string_ref

Calls L<unsafe_render_value|"unsafe_render_value">.

Dies if I<value> renders to C<undef>.

Returns I<buffer>.  If I<buffer> is I<undef>, will create one.

=cut

sub render_value {
    my($self, $attr_name, $value, $source, $buffer) = @_;
    my($b) = '';
    $buffer = \$b unless $buffer;
    $self->die($attr_name, $source, 'value renders as undef')
	unless $self->unsafe_render_value(
	    $attr_name, $value, $source, $buffer);
    return $buffer;
}

=for html <a name="unsafe_initialize_attr"></a>

=head2 unsafe_initialize_attr(string attr_name) : any

Calls L<initialize_value|"initialize_value"> on I<attr_name>'s value.
Calls I<unsafe_get> to initialize the attribute.

Returns value which may be C<undef>.

=cut

sub unsafe_initialize_attr {
    my($self, $attr_name) = @_;
    return $self->initialize_value($attr_name, $self->unsafe_get($attr_name));
}

=for html <a name="unsafe_render_attr"></a>

=head2 unsafe_render_attr(string attr_name, any source, string_ref buffer) : boolean

Retrieves I<attr_name> from I<self> and calls
L<unsafe_render_value|"unsafe_render_value"> on the result.

=cut

sub unsafe_render_attr {
    my($self, $attr_name, $source, $buffer) = @_;
    return $self->unsafe_render_value(
	$attr_name, $self->unsafe_get($attr_name), $source, $buffer);
}

=for html <a name="unsafe_render_value"></a>

=head2 unsafe_render_value(string attr_name, any value, any source, string_ref buffer) : boolean

Evaluates I<value>.  If is a constant, simply appends to I<buffer>.  If it
is a widget value (array_ref), calls I<source>C<-E<gt>get_widget_value>, to get
the value.  If the resultant value or original value is a
L<Bivio::UI::Widget|Bivio::UI::Widget>, calls put_and_initialize and render
on the widget.

The result is appended to I<buffer>.  If the value or widget value is C<undef>,
returns false and I<buffer> is unmodified.  I<buffer> should be a reference
to a defined value, so that widgets can call C<length> and other functions
with it.

I<attr_name> is used for debugging only.

Dies if value is or widget value results in a reference which is not a
Widget.

=cut

sub unsafe_render_value {
    my($self, $attr_name, $value, $source, $buffer) = @_;
    return 0 unless defined($value);
    $value = $self->unsafe_resolve_widget_value($value, $source);
    return 0 unless defined($value);
    if (ref($value) && UNIVERSAL::isa($value, __PACKAGE__)) {
	$value->put_and_initialize(parent => undef)
	    unless $value->has_keys('parent');
	$value->render($source, $buffer);
    }
# removed until all director widgets are fixed up
#    elsif (ref($value) && UNIVERSAL::can($value, 'as_string')) {
#	$$buffer .= $value->as_string;
#    }
    else {
        Bivio::IO::Alert->warn('rendering ref as string: ', $value)
                if ref($value);
	$$buffer .= $value;
    }
    return 1;
}

=for html <a name="resolve_ancestral_attr"></a>

=head2 resolve_ancestral_attr(string attr_name, any source) : string

Calls unsafe_resolve_widget_value.

Dies if there was no attribute or is C<undef>.

Returns I<buffer>.  If I<buffer> is I<undef>, will create one.

=cut

sub resolve_ancestral_attr {
    return _resolve_attr(ancestral_get => @_);
}

=for html <a name="resolve_attr"></a>

=head2 resolve_attr(string attr_name, any source) : string

Calls unsafe_resolve_widget_value.

Dies if there was no attribute or is C<undef>.

Returns I<buffer>.  If I<buffer> is I<undef>, will create one.

=cut

sub resolve_attr {
    return _resolve_attr(get => @_);
}

=for html <a name="unsafe_resolve_widget_value"></a>

=head2 unsafe_resolve_widget_value(array_ref value, any source) : any

Recursively eliminate array_ref widget values.

=cut

sub unsafe_resolve_widget_value {
    my($self, $value, $source) = @_;
    my($i) = 10;
    while (ref($value) eq 'ARRAY') {
	$value = $source->get_widget_value(@$value);
	return undef unless defined($value);
	$self->die(
	    $source, 'infinite loop trying to ',
	    ' unwind widget value: ', $value,
	) if --$i < 0;
    }
    return $value;
}

#=PRIVATE METHODS

sub _resolve_attr {
    my($method, $self, $attr_name, $source) = @_;
    my($res) = $self->unsafe_resolve_widget_value(
	$self->$method($attr_name), $source,
    );
    $self->die($attr_name, $source, 'attribute resolves as undef')
	unless defined($res);
    return $res;
}

=head1 COPYRIGHT

Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
