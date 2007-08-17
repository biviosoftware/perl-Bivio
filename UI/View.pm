# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::View;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::IO::Trace;
use Bivio::UI::Facade;
use Bivio::UI::ViewLanguage;

# C<Bivio::UI::View> presents output to the user.  You write programs to
# initialize view instances.  The program defines attributes on the view which
# defines the behavior of the view.  You can retrieve them using the
# L<Bivio::Collection::Attributes|Bivio::Collection::Attributes> interface.
# See the ATTRIBUTES section for the list of attributes.
#
# A view has four distinct phases: instantiation, initialization,
# pre-execution, execution.
# If I<Facade.want_local_file_cache> is true, the views are cached
# with the first two phases complete.
#
# When you call L<execute|"execute">, you (may) evaluate a view program
# definition and interpretation of the programming language is defined in
# L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>.
#
# Initialization occurs implicitly after evaluation.  Widgets contained in
# attributes are initialized at this time.  The view is ready to be executed.
#
# Pre-execution allows views to prepare state for the view's widgets.
# Typically, pre-execution is only used during prototyping, because
# it allows views to execute business logic outside of the widgets.
#
# Execution generates the output by rendering the widget defined in the
# I<view_main> attribute.  The resultant buffer created by the I<view_main>
# widget is passed to L<Bivio::Agent::Reply|Bivio::Agent::Reply>, which will
# return the value to the user.
#
# View asks I<view_main> the type of the output buffer by calling
# L<get_content_type|Bivio::UI::Widget/"get_content_type">.  This type may be
# dynamic, so you could build a widget hierarchy that, for example, rendered in
# application/pdf, text/html, or text/plain.  This might come in handy if you are
# trying to support multiple output devices.
#
# A view program is evaluated once to establish a view's attributes.  After
# evaluation, the attributes may not be modified.  A view should have no
# transient state, because views may be shared or rendered in arbitrary contexts.
#
# Views are tree structured.  There is always a I<root view>, a view without
# parents.  Child views have children of their own.  The relationship of parents
# to children is established by each child, by defining a I<view_parent>
# attribute.
#
# A view I<inherits> the attributes of its ancestors.  Inheritance may be
# overriden by children.  This allows children to modify the behavior of their
# ancestors.  For example, a child might want to change the page background color
# defined in an ancestor.  This only is allowed if the ancestor defines an
# attribute, i.e. although the child can change ancestor behavior, the ancestor
# defines what behaviors are modifiable through the declaration of attributes
# (with or without defaults).
#
# L<Bivio::UI::Widget|Bivio::UI::Widget> defines widget interface.  There are
# three phases in the life of a widget: creation (new), initialization
# (initialize), and rendering (render).  Rendering happens over and over again.
# Creation and initialization happen once.  The widget phases occur during the
# parallel phases in the view.
#
# A view creates widgets by calling them from a program:
#
#     view_main(Join(['Hello', ' world']));
#
# Here the I<Join> widget is created to concatenate two items: 'Hello' and
# 'world'.  It is also the I<view_main> widget.  This is almost a complete view
# program. The one missing step is telling ViewLanguage where to find the Join
# widget.
#
# Views are very general.  They aren't specific to HTML, email, XML, PDF, or any
# other display language.  The view programmer must tell the ViewLanguage what
# type of widgets should be loaded.  The
# L<view_class_map|Bivio::UI::ViewLanguage/"view_class_map"> function tells the
# ViewLanguage and the ClassLoader where to find widgets.  A class map is defined
# in your configuration file and has a name and a path.  You can have as many
# class maps as you like in the configuration.  The view or its parents need only
# specify the map's name.
#
#
# View instances present values to users.  The values come from many sources.
# Some are constants in the view, e.g. 'Hello' and ' world' in the first example.
# The request object is the source of dynamic values.  The view program passes
# widget values to the widgets.  Here's an example:
#
#     view_main(Join(['Hello ', ['auth_user', 'display_name']]));
#
# The widget value is:
#
#     ['auth_user', 'display_name']
#
# which gets the I<auth_user> attribute from the current request and accesses the
# I<display_name> value.  A widget value is an array_ref (a list in square
# brackets), which contains a list of qualifiers.  See
# L<Bivio::UI::WidgetValueSource|Bivio::UI::WidgetValueSource>
# for a complete description of widget values and their sources.
#
# There's a problem in the above example: I<auth_user> may be undefined.  The
# view execution will throw an exception in this case.  That's where a
# L<Director|Bivio::UI::Widget::Director> widget comes in handy:
#
#     view_main(Join(['Hello ',
#         Director(['auth_user'],
#             undef,
#             Join(['auth_user', 'display_name']),
#             Join('Visitor'),
#         ),
#     ]));
#
#
# Now we have three levels of widgets in our view.  The top level is the Join
# which is the parent of a Director which is the parent of the two Joins at the
# end.  During execution, the top-level Join goes through its list of views.  It
# adds 'Hello ' to its buffer followed by telling the Director to render itself.
# The Director has four values: control, value to widget map, default widget, and
# C<undef> widget.  The control is a widget value which retrieves the
# I<auth_user>.  We don't care what its specific value is.  If it has any value
# at all, it tells the C<Join(['auth_user', 'display_name'])> to render.  If
# there is no I<auth_user>, it tells C<undef> widget to render, which will result
# in 'Visitor' being added to the buffer.
#
# The Director widget is critical to building views.  There are many other
# standard widgets.  Some are content type specific and others are general like
# the Join and Director widgets.  The widget values defined in the views
# control the dynamic flow of execution.
#
#
# View attributes are defined in view programs.
#
#
# view_class_map : string (required ancestrally)
#
# Identifies the Widget load path defined in the ClassLoader configuration.
#
# See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.
#
# view_file_name : string (computed)
#
# The absolute path to the view program.  This is for informational purposes.
# The view program may be loaded from a database, so use this value for
# debugging purposes only.
#
# view_is_executable : boolean (computed)
#
# If a view contains an attribute whose value is C<undef>, it cannot be executed.
# Parent views declare attributes to be filled in by children.
#
# view_main : Bivio::UI::Widget (required ancestrally)
#
# How to render the view.
#
# See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.
#
# view_name : string (computed)
#
# The name of this view.  Every view has a name.  The name may does not contain
# the L<SUFFIX|"SUFFIX"> (C<.bview>) or the ClassLoader qualifier (C<View.>).
# View names are otherwise just relative file names (no '.' or '..' are allowed).
#
# View names are globally unique to an application invocation.  They are used to
# identify view parents.
#
# view_parent : string
#
# How the view inherits attributes.
#
# See L<Bivio::UI::ViewLanguage::view_class_map|Bivio::UI::ViewLanguage/"view_class_map">.
#
# view_pre_execute : code_ref
#
# A code reference to be execute prior to each call to L<render|"render">.
#
# view_shortcuts : Bivio::UI::ViewShortcutsBase
#
# The class that defines application specific shortcut functions available
# to view programs.  These functions always C<vs_>.
#
# See L<Bivio::UI::ViewLanguage::view_shortcuts|Bivio::UI::ViewLanguage/"view_shortcuts">.
#
#
#
#
# Die.attrs.view_stack : array_ref
#
# Created by L<execute|"execute"> and used to identify the stack of all views
# being rendered at the time of an exception.  Used for debugging purposes only.
#
# Request.uri : string
#
# The name of the view (sans I<Text.view_execute_uri_prefix>) rendered
# by L<execute_uri|"execute_uri">.
#
# Text.view_execute_uri_prefix : string
#
# The root of all views returned by L<execute_uri|"execute_uri">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE, $_CURRENT, $_CURRENT_FACADE);
my($_CACHE) = {};
my($_CLASSES);

sub SUFFIX {
    # Returns C<.bview>, the suffix for view files.
    return shift->use('View.LocalFile')->SUFFIX;
}

sub as_string {
    my($self) = @_;
    # Shows file name for I<self>.
    return 'View.'
	. $self->simple_package_name
	. (ref($self) ? '[' . ($self->unsafe_get('view_name') || '?') . ']'
	       : '');
}

sub call_main {
    my($proto, $view_name, $req) = @_;
    # Return the result of calling execute on the widget rendered by view_main
    my($result);
    my($self) = _get_instance($proto, $view_name, $req);
    Bivio::Die->die($self, ': view is not terminal, contains undef values')
        unless $self->get('view_is_executable');
    _trace($self) if $_TRACE;
    my($die) = do {
	# Used by the view values
	local($_CURRENT) = $self;
	$req->put(__PACKAGE__, $self);
	Bivio::Die->catch(sub {
	    $self->pre_call_main($req);
	    _pre_execute($self, $req);
	    $result = $self->ancestral_get('view_main')->execute($req);
	    $self->post_call_main($result, $req);
	    return;
	});
    };
    if ($_CURRENT) {
	$req->put(__PACKAGE__, $_CURRENT);
    }
    else {
	$req->delete(__PACKAGE__);
    }
    if ($die) {
	push(@{$die->get('attrs')->{view_stack} ||= []}, $self->as_string);
	$die->throw;
	# DOES NOT RETURN
    }
    return $result;
}

sub compile_die {
    my($view_name, @msg) = @_;
    # Dies with appropriate params.
    Bivio::Die->throw('DIE', {
	message => Bivio::IO::Alert->format_args(@msg),
	entity => $view_name,
	program_error => 1,
    });
    # DOES NOT RETURN
}

sub execute {
    # Executes view identified by I<view_name> and puts result on reply of I<req>.
    # If I<view_name> is a string_ref, saves as I<view_code> and assigns
    # anonymous values to view_name and view_file_name attributes.
    #
    # Always returns false.
    shift->call_main(@_);
    return 0;
}

sub execute_task_item {
    # Calls execute.
    return shift->execute(@_);
}

sub initialize_by_facade {
    my($proto, $facade) = @_;
    # Initializes all views in a facade.  Only called if caching turned on.
#TODO: Need to implement
    return $proto;
}

sub internal_set_parent {
    my($self, $parent_name) = @_;
    # Sets the parent.
    # COUPLING: We catch recursion, because it maintains the list
    # of all views.  "parent" is a special word used by Collection::Attributes.
    # We define both to keep consistency in the "view_*" attribute space.
    my($parent) = _get_instance($self, $parent_name);
    $self->put(view_parent => $parent, parent => $parent);
    return;
}

sub post_call_main {
    # Called after view_main is executed, but only if view doesn't throw an exception.
    return;
}

sub pre_call_main {
    # Called before view_main is executed and before pre_execute subs, if any.
    return;
}

sub render {
    my($proto, $view_name, $req) = @_;
    # Renders view identified by I<view_name> and returns the result.
    #
    # Always returns false.
    my($reply) = $req->get('reply');
    my($o) = $reply->unsafe_get_output;
    Bivio::Die->die($view_name, ': output already exists: ', $o)
        if $o;
    shift->call_main(@_);
    return $reply->delete_output
	|| Bivio::Die->die($view_name, ': no output was rendered');
}

sub unsafe_get_current {
    # Gets the view being rendered or evaled.  May return C<undef>.
    #
    # B<Use for debugging only.>
    return $_CURRENT;
}

sub _clear_children {
    my($object, $seen) = @_;
    return if $seen->{$object}++;
    $object->internal_clear_read_only->delete(qw(parent view_parent));
    foreach my $v (values(%{$object->get_shallow_copy})) {
	next unless ref($v);
	foreach my $o (
	    ref($v) eq 'ARRAY' ? @$v : ref($v) eq 'HASH' ? values(%$v) : $v,
	) {
	    _clear_children($o, $seen)
		if $object->is_blessed($o, 'Bivio::Collection::Attributes');
	}
    }
    return;
}

sub _destroy {
    my($self, $die) = @_;
    push(@{$die->get('attrs')->{view_stack} ||= []}, $self->as_string)
	if $die;
    delete($_CACHE->{$self->get_or_default(view_cache_name => '')});
    if (my $req = Bivio::Agent::Request->get_current) {
	$req->delete(__PACKAGE__);
    }
    _clear_children($self, {});
    $die->throw
	if $die;
    return;
}

sub _get_instance {
    my($proto, $name, $req_or_facade) = @_;
    # Returns an instance of view_name for this facade.  req_or_facade may
    # be undef in which case $_CURRENT_FACADE is used.
    my($name_arg) = $name;
    if ($name =~ /^(\w+)->(.+)/) {
	$name = $name_arg = $2;
	$proto = $proto->use("View.$1");
    }
    elsif ((ref($proto) || $proto) eq __PACKAGE__) {
	$proto = $proto->use(View => ref($name) ? 'Inline' : 'LocalFile');
    }
    $proto->compile_die($name_arg, ": view_name may not contain '.' or '..'")
	if $name =~ m!(^|/)\.\.?(/|$)!;
    my($facade) = $req_or_facade
	? Bivio::UI::Facade->get_from_request_or_self($req_or_facade)
	: $_CURRENT_FACADE;
    Bivio::Die->throw('NOT_FOUND', {
	message => 'view not found',
	entity => $name_arg,
	class => $proto,
	facade => $facade,
    }) unless my $self = $proto->unsafe_new($name_arg, $facade)
	|| !$proto->isa('Bivio::UI::View::LocalFile')
	&& $proto->use('View.LocalFile')->unsafe_new($name_arg, $facade);
    my($unique) = join('->', ref($self), $self->absolute_path);
    if ($_CACHE->{$unique}) {
	$proto->compile_die($name_arg, ': called recursively')
	    unless ref(my $cache = $_CACHE->{$unique});
	_trace($unique, ': cache hit=', $cache) if $_TRACE;
	return $cache;
    }
    $self->put_unless_exists(
	view_name => $name_arg,
	view_cache_name => $unique,
    );
    my($die) = do {
	local($_CURRENT) = $_CACHE->{$unique} = -1;
	local($_CURRENT_FACADE) = $facade;
	Bivio::UI::ViewLanguage->eval($self);
    };
    delete($_CACHE->{$unique});
    _destroy($self, $die)
	if $die;
    # Don't store if $unique contains a stringified reference
    return $self
	if $unique =~ /\(0x\w+\)/i
	|| !$facade->get('want_local_file_cache');
    _trace($unique, ': cached as ', $self) if $_TRACE;
    return $_CACHE->{$unique} = $self->internal_clear_read_only
	->put(view_is_cached => 1)->set_read_only;
}

sub _pre_execute {
    my($self, $req) = @_;
    # Recursively invokes the view_pre_execute code_ref for the parents and
    # this view.
    my($parent, $code) = $self->unsafe_get(qw(parent view_pre_execute));
    _pre_execute($parent, $req) if $parent;
    $code->($req) if $code;
    return;
}

1;
