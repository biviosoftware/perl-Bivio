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

A view has three distinct phases: evaluation, initialization, and execution.

When you call L<get_instance|"get_instance">, you evaluate a view program.  The
definition and interpretation of the programming language is defined in
L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>.

Initialization occurs implicitly after evaluation.  Widgets contained in
attributes are initialized at this time.  The view is ready to be executed.

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
brackets), which contains a list of qualifiers.

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


=head1 ATTRIBUTES

View attributes are defined in view programs.

=over 4

=item view_class_map : string (required ancestrally)

Identifies the Widget load path defined in the ClassLoader configuration.

See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.

=item view_file_last_modified : Bivio::Type::DateTime (computed)

The date and time when the view program last modified.

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
the L<SUFFIX|"SUFFIX"> (C<.bview>) or the ClassLoader qualifier (C<View#>).
View names are otherwise just relative file names (no '.' or '..' are allowed).

View names are globally unique to an application invocation.  They are used to
identify view parents.

=item view_parent : string

How the view inherits attributes.

See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.


=item view_shortcuts : Bivio::UI::ViewShortcutsBase

The class that defines application specific shortcut functions available
to view programs.  These functions always C<vs_>.

See L<Bivio::UI::ViewLanguage::view_shortcuts|Bivio::UI::ViewLanguage/"view_shortcuts">.

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
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::UI::ViewLanguage;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_SUFFIX) = __PACKAGE__->SUFFIX;
my($_SEP) = Bivio::IO::ClassLoader->MAP_SEPARATOR;
# All elements have a trailing '/'
my($_LOAD_PATH) = undef;
my($_CURRENT);
my(%_CACHE);
Bivio::IO::Config->register({
    load_path => Bivio::IO::Config->REQUIRED,
});

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 get_instance() : self

Returns I<self> if called without an argument and by an instance.

=head2 static get_instance(string view_name) : Bivio::UI::View

Returns the instance for the given I<file_name> file.  Caches the
result so that only one instance of a view exists at any one time.

=cut

sub get_instance {
    my($proto, $view_name) = @_;
    return $proto if ref($proto) && !$view_name;

    my($self) = $proto->new({
	view_name => $view_name,
    });
    _find_file($self);
    $view_name = $self->get('view_name');

    # In the cache and up to date?
    if ($_CACHE{$view_name}) {
	my($cache) = $_CACHE{$view_name};
	$self->compile_die('called recursively') unless ref($cache);
#TODO: Race condition on package installs, because parents should be
# installed before children.
	return $cache if $self->get('view_file_last_modified')
		eq $cache->get('view_file_last_modified');

	# Invalidate cache
	delete($_CACHE{$view_name});
    }

    # Avoid recursion
    my($prev_current) = $_CURRENT;
    $_CURRENT = $_CACHE{$view_name} = -1;

    my($die) = Bivio::UI::ViewLanguage->eval($self);
    $_CURRENT = $prev_current;
    return $_CACHE{$view_name} = $self unless $die;

    delete($_CACHE{$view_name});
    push(@{$die->get('attrs')->{view_stack} ||= []}, $self);
    $die->throw;
    # DOES NOT RETURN
}

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

=head2 execute(Bivio::Agent::Request req) : boolean

Executes I<self> and puts result on reply of I<req>.

Always returns false.

=cut

sub execute {
    my($self, $req) = @_;
    Bivio::Die->die($self, ': view is not terminal, contains undef values')
		unless $self->get('view_is_executable');
    _trace($self) if $_TRACE;
    # Used by the view values
    my($prev_current) = $_CURRENT;
    $_CURRENT = $self;
    $req->put($_PACKAGE => $self);
    my($die) = Bivio::Die->catch(sub {
	    $self->ancestral_get('view_main')->execute($req);
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

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item load_path : array_ref (required)

A list of absolute directories which contain the I<bview> files.  All dirs
must exist at config time.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    my(@load_path);
    foreach my $p (@{$cfg->{load_path}}) {
	Bivio::Die->die($p, ": invalid directory in load path ($!)")
		    unless -d $p;
	push(@load_path, Bivio::Type::FileName->add_trailing_slash($p));
    }
    $_LOAD_PATH = \@load_path;
    return;
}

=for html <a name="handle_map_require"></a>

=head2 static handle_map_require(string map_name, string class_name, string map_class) : UNIVERSAL

Loads I<class_name> with L<get_instance|"get_instance">.

=cut

sub handle_map_require {
    my($proto, $map_name, $class_name, $map_class) = @_;
    return $proto->get_instance($class_name);
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

# _find_file(self) : array
#
# Sets view_file_last_modified and view_file_name.
#
sub _find_file {
    my($self) = @_;
    my($view_name) = $self->get('view_name');
    $self->compile_die("view_name may not contain '.' or '..'")
	    if $view_name =~ m!(^|/)\.\.?(/|$)!;
    $view_name =~ s!^/|/$!!g;
    $view_name =~ s!/+!/!g;
    $view_name =~ s/$_SUFFIX//og;

    my($file_name) = $view_name.$_SUFFIX;
    foreach my $p (@$_LOAD_PATH) {
	my($mtime) = (CORE::stat($p.$file_name))[9];
	return $self->put(
		view_name => $view_name,
		view_file_name => $p.$file_name,
		view_file_last_modified =>
			Bivio::Type::DateTime->from_unix($mtime)
	) if defined($mtime);
    }
    $self->compile_die('not found');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
