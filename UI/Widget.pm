# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Widget;
use strict;
$Bivio::UI::Widget::VERSION = sprintf('d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Widget - a renderable object

=head1 SYNOPSIS

    use Bivio::UI::Widget;
    Bivio::UI::Widget->new($attrs);

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

creates a new instance and binds the initial attributes.
Instantation is passive as far as the widgets are concerned, i.e.
attribute binding is the only action that occurs.

=item initialize

parses the attributes into an internal format which may result in the
creation of new widgets.  Attributes should not be modified by the
caller after initialization unless they are explicitly labeled
I<dynamic>. 

=item render

converts attributes and values into the target format.  Currently,
this is html, but could easily be gif, pdf, or javascript.  Widget
values are retrieved from a I<source> via the call
I<get_widget_value>.   This is the only method that a I<source> needs
to provide to the widget.  The main implementation is
L<Bivio::Collection::Attributes::get_widget_value|Bivio::Collection::Attributes/"get_widget_value">,
but other implementations exist.

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

=item defaulted

need not be supplied.  If not supplied, the default value will
be used.  Defaulted attributes are indicated with square brackets []
to the right of the type.

=item dynamic

are retrieved during rendering.  They must be supplied during
initialization, but the value may be change before each call to
render.  See
L<Bivio::UI::HTML::Widget::Indirect::value|Bivio::UI::HTML::Widget::Indirect/"item_value">
for an example.

=back

An attribute is declared in the I<ATTRIBUTES> section of the Widget.
The items define the name, the type, default value, and the kind
it is (required, inherited, etc.).

=head2 Values

Most widgets have an attribute called C<value>.  Some widgets have
several values.  A widget value may be static, but it typically
is dynamic.  It is a little script which is represented syntactically
as an array_ref.  Here are some of attributes which are expecting
widget values:

    value => ['mailhost'],
    src => ['Bivio::UI::Icon', 'next'],
    cells => [
	['RealmOwner.name'],
	['RealmUser.role', '->get_short_desc'],
    ],
    source => ['Bivio::Biz::Model::ClubUserList'],
    alt => ['auth_user', 'name', 'Bivio::UI::HTML::Format::Printf',
    		'The auth_user is %s'],

Let's go through each of these one by one:

=over 4

=item value

is an attribute of
L<Bivio::UI::HTML::Widget::String|Bivio::UI::HTML::Widget::String>.
The array_ref contains a single element, C<'mailhost'>.  When
String's render is called, it executes the following call:

    $source->get_widget_value(@{$fields->{value}})

The contents of the I<value> attribute have been squirreled away to an
internal field for efficiency.  The call dereferences the array_ref,
which causes C<'mailhost'> to be passed to C<get_widget_value> of
C<$source>.  Typically, C<$source> is a
L<Bivio::Agent::Request|Bivio::Agent::Request> which always
has an C<mailhost> attribute.  C<get_widget_value> sees that
the attribute exists and returns the value to String, which
in turn renders it with the appropriate font decoration as described
by the other String attributes.

=item src

is an attribute of
L<Bivio::UI::HTML::Widget::Image|Bivio::UI::HTML::Widget::Image>.
This one is slightly more complex.  L<Bivio::UI::Icon|Bivio::UI::Icon>
is a class.  It is not an attribute name of the request.
During rendering, Image calls C<$source-E<gt>get_widget_value> which
determines that C<'Bivio::UI::Icon'> is not an attribute, but is a
class which I<can> C<get_widget_value>.  It shifts off the
C<'Bivio::UI::Icon'> and uses it as the object and makes the
following call:

    return Bivio::UI::Icon->get_widget_value('next');

Icon's C<get_widget_value> returns the information for the
C<'next'> icon, whatever that is.
    
=item source

is an attribute of
L<Bivio::UI::HTML::Widget::HTML::Table|Bivio::UI::HTML::Widget::Table>.
This widget value looks like a class, but there is a trick.  All
models, which load themselves successfully, are put as attributes
on the request by their class name.  So although
C<Bivio::Biz::Model::ClubUserList> I<can> C<get_widget_value>,
it won't.  Instead, the value of the
C<'Bivio::Biz::Model::ClubUserList'> instance which was loaded
successfully is retrieved.

=item cells

is an attribute of
L<Bivio::UI::HTML::Widget::HTML::Table|Bivio::UI::HTML::Widget::Table>.
This is a different type of value attribute.  It is an array_ref of
value attributes.  Table renders a series of cells.  For convenience
of the configurer, it allows you to specify the widget values sans
widgets!  It then wraps a String instance around each value.  This
avoids a lot of boilerplate.

Table is unique in that it changes the C<$source> dynamically by
asking it's C<$source> for a widget value.  This is the use
of the I<source> attribute discussed just above.  The ListModel
becomes the source for the headings and cells of the Table.

The two widget values (cells) are rendered by two independent String
widgets whose parent is the Table.   The first value
retrieves the attribute C<'RealmOwner.name'> from the C<$source>,
which is the ListModel.  The second cell's value  retrieves
C<'RealmUser.role'> from the ListModel.
However, I<RealmUser.role> is an Enum.  What should be displayed?
The second argument begins with C<-E<gt>>
which tells C<get_widget_value> to call the result of the first
argument with the second.  The result is calling the Enum's
C<get_short_desc> method to retrieve the short description for
the RealmUser's role.

=item alt

is an attribute of
L<Bivio::UI::HTML::Widget::Image|Bivio::UI::HTML::Widget::Image>.
This demonstrates "extreme" cascading of C<get_widget_value> arguments.
The first argument causes the C<auth_user> attribute from the
Request to be retrieved, which is a
L<Bivio::Biz::Model::RealmOwner|Bivio::Biz::Model::RealmOwner>
object.  The RealmOwner has a property C<name>, which is retrieved
from this particular instance.

There are more arguments and first argument is a class which
I<can> C<get_widget_value>, so the following call is executed:

    return Bivio::UI::HTML::Format::Printf->get_widget_value(
        $name, 'The auth_user is %s');
  
This particular class is known as a I<formatter>, used for
the purpose of controlling rendering via the configuration
of a widget.

=back

The C<get_widget_value> interface will be evolve as needs
progress.  With perl's powerful introspection mechanisms, we
have lots of "hooks" to grow.  For example, we might have
a widget value argument which is a CODE ref which would allow
the configurer to specify an arbitrary perl subroutine to
retrieve the widget value.

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

=head2 Current Request

Some widgets assume there is a request.  While it might make
sense to have dynamic binding through widget values, there is
a well-known call
L<Bivio::Agent::Request::get_current|Bivio::Agent::Request/"get_current">,
which returns the current request.
It makes sense to avoid clutter in the configuration and
instead assume there is a request for those widgets that need it.
An example is
L<Bivio::UI::HTML::Widget::TextTabMenu|Bivio::UI::HTML::Widget::TextTabMenu>
which needs to know the current task (to highlight it in the
menu) and whether all tasks are executable by the current
I<auth_user>.

In general, widgets get all their values via
C<get_widget_value>.

=head2 Optimizations

Rendering is expensive.  During initialization, the widgets
render as much as they can and store this "pre-rendered" values
in their private fields.

In some cases, a widget is rendering
a completely static value, e.g. a label.  In this case, the
widget can indicate to its parent that it C<is_constant>.
The parent widget can avoid the call to the widget's
C<render> method.  The widget itself is obligated to
return the constant string as efficiently as possible as well.

For convenience, C<is_constant> is only valid after the first
call to render.  This is because the widget can't render until
it has a C<$source>, which it only sees during rendering.
Some sources are always constant, e.g. Icons.

Only a few widgets keep track of their children's C<is_constant>
value.  One of these is
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>,
which simply joins together all its values, serially.  If all
its values are constant, the Join's C<is_constant> will also
be true.

=head2 Conclusion

Widgets have complex implementations, because they are providing
multiple options to their configurers.  The configuration, in turn,
should be simple and as syntax free as possible.

=head1 ATTRIBUTES

=over 4

=item parent : Bivio::UI::HTML::Widget []

This widget's "owner".  The ancestral hierarchy is checked
for attributes, i.e. attributes are inherited from parents.
See
L<Bivio::Collection::Attributes::ancestral_get|Bivio::Collection::Attributes/"ancestral_get">.

=back

=cut


#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::Widget

=cut

sub new {
    return Bivio::Collection::Attributes::new(@_);
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes the widgets internal structures.  Widgets should cache static
attributes.  Widgets initialize should be callable more than once.

=cut

sub initialize {
    die('abstract method');
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will this widget always render exactly the same way?
May only be called after the first render call.

Returns false by default.

=cut

sub is_constant {
    return 0;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Appends the value of the widget to I<buffer>.

=cut

sub render {
    die('abstract method');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
