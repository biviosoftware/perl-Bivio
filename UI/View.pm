# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::View;
use strict;
$Bivio::UI::View::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::View::VERSION;

=head1 NAME

Bivio::UI::View - a language for creating hierarchies of UI widgets

=head1 SYNOPSIS

    use Bivio::UI::View;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::UI::View::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::UI::View> presents output to the user.  You write programs to
initialize view instances.  The program defines attributes on the view which
defines the behavior of the view.  You can retrieve them using the
L<Bivio::Collection::Attributes|Bivio::Collection::Attributes> interface.
See the ATTRIBUTES section for the list of attributes.

A view has four distinct phases: instantiation, initialization,
pre-execution, execution.
If I<Facade.want_local_file_cache> is true, the views are cached
with the first two phases complete.

When you call L<execute|"execute">, you (may) evaluate a view program
definition and interpretation of the programming language is defined in
L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>.

Initialization occurs implicitly after evaluation.  Widgets contained in
attributes are initialized at this time.  The view is ready to be executed.

Pre-execution allows views to prepare state for the view's widgets.
Typically, pre-execution is only used during prototyping, because
it allows views to execute business logic outside of the widgets.

Execution generates the output by rendering the widget defined in the
I<view_main> attribute.  The resultant buffer created by the I<view_main>
widget is passed to L<Bivio::Agent::Reply|Bivio::Agent::Reply>, which will
return the value to the user.

View asks I<view_main> the type of the output buffer by calling
L<get_content_type|Bivio::UI::Widget/"get_content_type">.  This type may be
dynamic, so you could build a widget hierarchy that, for example, rendered in
application/pdf, text/html, or text/plain.  This might come in handy if you are
trying to support multiple output devices.

A view program is evaluated once to establish a view's attributes.  After
evaluation, the attributes may not be modified.  A view should have no
transient state, because views may be shared or rendered in arbitrary contexts.

Views are tree structured.  There is always a I<root view>, a view without
parents.  Child views have children of their own.  The relationship of parents
to children is established by each child, by defining a I<view_parent>
attribute.

A view I<inherits> the attributes of its ancestors.  Inheritance may be
overriden by children.  This allows children to modify the behavior of their
ancestors.  For example, a child might want to change the page background color
defined in an ancestor.  This only is allowed if the ancestor defines an
attribute, i.e. although the child can change ancestor behavior, the ancestor
defines what behaviors are modifiable through the declaration of attributes
(with or without defaults).

L<Bivio::UI::Widget|Bivio::UI::Widget> defines widget interface.  There are
three phases in the life of a widget: creation (new), initialization
(initialize), and rendering (render).  Rendering happens over and over again.
Creation and initialization happen once.  The widget phases occur during the
parallel phases in the view.

A view creates widgets by calling them from a program:

    view_main(Join(['Hello', ' world']));

Here the I<Join> widget is created to concatenate two items: 'Hello' and
'world'.  It is also the I<view_main> widget.  This is almost a complete view
program. The one missing step is telling ViewLanguage where to find the Join
widget.

Views are very general.  They aren't specific to HTML, email, XML, PDF, or any
other display language.  The view programmer must tell the ViewLanguage what
type of widgets should be loaded.  The
L<view_class_map|Bivio::UI::ViewLanguage/"view_class_map"> function tells the
ViewLanguage and the ClassLoader where to find widgets.  A class map is defined
in your configuration file and has a name and a path.  You can have as many
class maps as you like in the configuration.  The view or its parents need only
specify the map's name.

=head3 Values

View instances present values to users.  The values come from many sources.
Some are constants in the view, e.g. 'Hello' and ' world' in the first example.
The request object is the source of dynamic values.  The view program passes
widget values to the widgets.  Here's an example:

    view_main(Join(['Hello ', ['auth_user', 'display_name']]));

The widget value is:

    ['auth_user', 'display_name']

which gets the I<auth_user> attribute from the current request and accesses the
I<display_name> value.  A widget value is an array_ref (a list in square
brackets), which contains a list of qualifiers.  See
L<Bivio::UI::WidgetValueSource|Bivio::UI::WidgetValueSource>
for a complete description of widget values and their sources.

There's a problem in the above example: I<auth_user> may be undefined.  The
view execution will throw an exception in this case.  That's where a
L<Director|Bivio::UI::Widget::Director> widget comes in handy:

    view_main(Join(['Hello ',
        Director(['auth_user'],
            undef,
            Join(['auth_user', 'display_name']),
            Join('Visitor'),
        ),
    ]));


Now we have three levels of widgets in our view.  The top level is the Join
which is the parent of a Director which is the parent of the two Joins at the
end.  During execution, the top-level Join goes through its list of views.  It
adds 'Hello ' to its buffer followed by telling the Director to render itself.
The Director has four values: control, value to widget map, default widget, and
C<undef> widget.  The control is a widget value which retrieves the
I<auth_user>.  We don't care what its specific value is.  If it has any value
at all, it tells the C<Join(['auth_user', 'display_name'])> to render.  If
there is no I<auth_user>, it tells C<undef> widget to render, which will result
in 'Visitor' being added to the buffer.

The Director widget is critical to building views.  There are many other
standard widgets.  Some are content type specific and others are general like
the Join and Director widgets.  The widget values defined in the views
control the dynamic flow of execution.

=head1 VIEW ATTRIBUTES

View attributes are defined in view programs.

=over 4

=item view_class_map : string (required ancestrally)

Identifies the Widget load path defined in the ClassLoader configuration.

See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.

=item view_file_name : string (computed)

The absolute path to the view program.  This is for informational purposes.
The view program may be loaded from a database, so use this value for
debugging purposes only.

=item view_is_executable : boolean (computed)

If a view contains an attribute whose value is C<undef>, it cannot be executed.
Parent views declare attributes to be filled in by children.

=item view_main : Bivio::UI::Widget (required ancestrally)

How to render the view.

See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.

=item view_name : string (computed)

The name of this view.  Every view has a name.  The name may does not contain
the L<SUFFIX|"SUFFIX"> (C<.bview>) or the ClassLoader qualifier (C<View.>).
View names are otherwise just relative file names (no '.' or '..' are allowed).

View names are globally unique to an application invocation.  They are used to
identify view parents.

=item view_parent : string

How the view inherits attributes.

See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.

=item view_pre_execute : code_ref

A code reference to be execute prior to each call to L<render|"render">.

=item view_shortcuts : Bivio::UI::ViewShortcutsBase

The class that defines application specific shortcut functions available
to view programs.  These functions always C<vs_>.

See L<Bivio::UI::ViewLanguage::view_shortcuts|Bivio::UI::ViewLanguage/"view_shortcuts">.

=back

=head1 REFERENCE ATTRIBUTES

=over 4

=item Die.attrs.view_stack : array_ref

Created by L<execute|"execute"> and used to identify the stack of all views
being rendered at the time of an exception.  Used for debugging purposes only.

=item Request.uri : string

The name of the view (sans I<Text.view_execute_uri_prefix>) rendered
by L<execute_uri|"execute_uri">.

=item Text.view_execute_uri_prefix : string

The root of all views returned by L<execute_uri|"execute_uri">.

=back

=cut

=head1 CONSTANTS

=cut

=for html <a name="SUFFIX"></a>

=head2 SUFFIX : string

Returns C<.bview>, the suffix for view files.

=cut

sub SUFFIX {
    return '.bview';
}

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::UI::Facade;
use Bivio::UI::LocalFileType;
use Bivio::UI::ViewLanguage;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SUFFIX) = __PACKAGE__->SUFFIX;
my($_CURRENT);
# Only used during compiles
my($_CURRENT_FACADE);
my(%_CACHE);

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Shows file name for I<self>.

=cut

sub as_string {
    my($self) = @_;
    return 'View['.$self->get('view_name').']';
}

=for html <a name="compile_die"></a>

=head2 compile_die(string msg, ...) : string

Dies with appropriate params.

=cut

sub compile_die {
    my($view_name, @msg) = @_;
    Bivio::Die->throw('DIE', {
	message => Bivio::IO::Alert->format_args(@msg),
	entity => $view_name,
	program_error => 1,
    });
    # DOES NOT RETURN
}

=for html <a name="execute"></a>

=head2 static execute(string view_name, Bivio::Agent::Request req) : boolean

Executes view identified by I<name> and puts result on reply of I<req>.

Always returns false.

=cut

sub execute {
    my($proto, $view_name, $req) = @_;
    my($self) = _get_instance($proto, $view_name, $req);
    Bivio::Die->die($self, ': view is not terminal, contains undef values')
		unless $self->get('view_is_executable');
    _trace($self) if $_TRACE;
    # Used by the view values
    my($prev_current) = $_CURRENT;
    $_CURRENT = $self;
    $req->put($_PACKAGE => $self);

    # Execute user defined code
    my($die) = Bivio::Die->catch(sub {
	_pre_execute($self, $req);
	$self->ancestral_get('view_main')->execute($req);
	return;
    });

    if ($prev_current) {
	$req->put($_PACKAGE => $prev_current);
    }
    else {
	$req->delete($_PACKAGE);
    }
    $_CURRENT = $prev_current;
    if ($die) {
	push(@{$die->get('attrs')->{view_stack} ||= []}, $self);
	$die->throw;
	# DOES NOT RETURN
    }
    return 0;
}

=for html <a name="execute_uri"></a>

=head2 static execute_uri(Bivio::Agent::Request req) : boolean

Uses I<Request.uri> as the view name and executes it.  May compile the
view dynamically.  The I<Request.uri> is prefixed with
I<Text.view_execute_uri_prefix>.

Dies with NOT_FOUND, if uri is not found as uri.

=cut

sub execute_uri {
    my($proto, $req) = @_;
    return $proto->execute(
	    Bivio::UI::Text->get_value('view_execute_uri_prefix', $req)
	    .'/'.$req->get('uri'), $req);
}

=for html <a name="initialize_by_facade"></a>

=head2 static initialize_by_facade(Bivio::UI::Facade facade)

Initializes all views in a facade.  Only called if caching turned on.

=cut

sub initialize_by_facade {
    my($proto, $facade) = @_;
#TODO: Need to implement
    return;
}

=for html <a name="internal_set_parent"></a>

=head2 internal_set_parent(string parent_name)

Sets the parent.

=cut

sub internal_set_parent {
    my($self, $parent_name) = @_;
    # COUPLING: We catch recursion, because it maintains the list
    # of all views.  "parent" is a special word used by Collection::Attributes.
    # We define both to keep consistency in the "view_*" attribute space.
    my($parent) = _get_instance($self, $parent_name);
    $self->put(view_parent => $parent, parent => $parent);
    return;
}

=for html <a name="unsafe_get_current"></a>

=head2 static unsafe_get_current() : Bivio::UI::View

Gets the view being rendered or evaled.  May return C<undef>.

B<Use for debugging only.>

=cut

sub unsafe_get_current {
    return $_CURRENT;
}

#=PRIVATE METHODS

# _clean_name(self, string_ref view_name)
#
# Removes extra slashes, checks syntax.
#
sub _clean_name {
    my($self, $view_name) = @_;
    $self->compile_die("view_name may not contain '.' or '..'")
	    if $$view_name =~ m!(^|/)\.\.?(/|$)!;
    $$view_name =~ s!^/|/$!!g;
    $$view_name =~ s!/+!/!g;
    $$view_name =~ s/$_SUFFIX//og;
    return;
}

# _get_instance(proto, string view_name, Bivio::Collection::Attributes req_or_facade) : Bivio::UI::View
#
# Returns an instance of view_name for this facade.  req_or_facade may
# be undef iwc $_CURRENT_FACADE is used.
#
sub _get_instance {
    my($proto, $view_name, $req_or_facade) = @_;

    # Canonicalize to help with caching and recursion checking
    _clean_name($proto, \$view_name);

    my($facade) = $req_or_facade
	    ? Bivio::UI::Facade->get_from_request_or_self($req_or_facade)
	    : $_CURRENT_FACADE;
    my($view_file_name) = $facade->get_local_file_name(
	    Bivio::UI::LocalFileType->VIEW, $view_name).$_SUFFIX;

    # In the cache and up to date?  We use the cache as a recursion
    # sentinel
    if ($_CACHE{$view_file_name}) {
	my($cache) = $_CACHE{$view_file_name};
	$proto->compile_die('called recursively') unless ref($cache);
	return $cache;
    }

    Bivio::Die->throw('NOT_FOUND', {
	message => 'view file not found',
	entity => $view_file_name,
	facade => $facade,
	view => $view_name,
    }) unless -r $view_file_name && -f _;

    my($self) = $proto->new({
	view_name => $view_name,
	view_file_name => $view_file_name,
    });

    # Set global state. We use the cache as a recursion sentinel, too.
    my($prev_current) = $_CURRENT;
    $_CURRENT = $_CACHE{$view_file_name} = -1;
    my($prev_facade) = $_CURRENT_FACADE;
    $_CURRENT_FACADE = $facade;

    # Try to compile
    my($die) = Bivio::UI::ViewLanguage->eval($self);

    # Unset global state
    $_CURRENT = $prev_current;
    $_CURRENT_FACADE = $prev_facade;
    delete($_CACHE{$view_file_name});

    if ($die) {
	# view_stack is used for debugging only
	push(@{$die->get('attrs')->{view_stack} ||= []}, $self);
	$die->throw;
	# DOES NOT RETURN
    }
    $_CACHE{$view_file_name} = $self if $facade->get('want_local_file_cache');
    return $self;
}

# _pre_execute(self, Bivio::Agent::Request req)
#
# Recursively invokes the view_pre_execute code_ref for the parents and
# this view.
#
sub _pre_execute {
    my($self, $req) = @_;
    my($parent, $code) = $self->unsafe_get(qw(parent view_pre_execute));
    _pre_execute($parent, $req) if $parent;
    $code->($req) if $code;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
