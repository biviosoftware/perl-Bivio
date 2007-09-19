# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewLanguage;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::File;
use Bivio::IO::Trace;

# C<Bivio::UI::ViewLanguage> defines the language used by
# L<Bivio::UI::View|Bivio::UI::View>.  Here's a simple
# view language file:
#
#     view_class_map('HTMLWidget');
#     view_main(Page({
#         ...,
#     });
#
# The first call to I<view_class_map> tells this module where to load
# widgets from.  The name is defined in the configuration for
# L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader>.
#
# The next call defines the main widget, i.e. the widget that
# will be called when the view is rendered by
# L<Bivio::UI::View::execute|Bivio::UI::View/"execute">.  All views
# must define a I<view_main> or a view's parents must define a main.
#
# A view may have a parent, e.g.:
#
#     view_parent('common');
#     view_put(page_body => Prose('hello, world!'));
#
# This view inherits its attributes from a view called C<common>.
# The C<common> view or its parents must define I<view_class_map> and
# I<view_main>.  This last attribute, I<page_body>, is application
# specific.  Reserved attributes, i.e. attributes defined in the
# view language, begin with the prefix I<view_>.  You may not define
# an application specific attribute which begins with I<view_>.  There
# are a few other restrictions which are defined by I<view_put>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);
our($_VIEW_IN_EVAL);

sub AUTOLOAD {
    # The widget and shortcut methods are dynamically loaded.
    return __PACKAGE__->call_method($AUTOLOAD, _args(@_));
}

sub call_method {
    my(undef, $autoload, $proto, @args) = @_;
    # Calls method or class contained in I<autoload>.  Using I<proto> and passing
    # I<args> as appropriate.
    #
    # If I<autoload> begins with a capital letter, it is assumed to be a class which
    # needs to be loaded via view_class_map.  If I<autoload> begins with C<vs_> it is
    # found in the view_shortcuts map.  Otherwise, I<autoload> must begin with
    # C<view_>, and is called in this module.
    my($method) = $autoload;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    my($view) = _assert_in_eval($autoload);
    if ($method =~ /^[A-Z]/) {
	my($map) = $view->ancestral_get('view_class_map', undef);
	_die("view_class_map() or view_parent() must be called before $method")
	    unless $map;
	my($class) = Bivio::IO::ClassLoader->unsafe_map_require($map, $method);
	return $class->new(@args)
	    if $class;
    }
    elsif ($method =~ /^view_/) {
	return $proto->$method(@args)
	    if $proto->can($method);
    }
    my($vs) = $view->ancestral_get('view_shortcuts', undef);
    if ($method =~ /^vs_/) {
	_die("view_shortcuts() or view_parent() must be called before $method")
	    unless $vs;
	_die("$method is not implemented by $vs or its superclass(es)")
	    unless $vs->can($method);
	return $vs->$method(@args);
    }
    return ($vs || Bivio::IO::ClassLoader->simple_require(
	'Bivio::UI::ViewShortcutsBase')
	)->view_autoload($method, \@args);
}

sub eval {
    my(undef, $value) = @_;
    # Compiles I<view.view_file_name> or I<view.view_code> (if defined).
    #
    # Returns C<undef> on success.  Returns die instance on failure.
    #
    #
    # Compiles I<code> within context of the current view being compiled.
    return UNIVERSAL::isa($value, 'Bivio::UI::View') ? _eval_view($value)
	: ref($value) eq 'SCALAR' ? _eval_code($value)
	: _die('eval: invalid argument (not a string_ref or view)');
}

sub new {
    # You cannot instantiate this class.
    Bivio::Die->die('this class may not be instantiated');
}

sub unsafe_get_eval {
    # USE ONLY FOR TESTING
    return $_VIEW_IN_EVAL;
}

sub view_class_map {
    my($proto, $map_name) = _args(@_);
    # Identifies the load path for Widgets specified in view programs.
    # I<map_name> is a string which identifies a configured class path
    # (L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader>).
    # May be used to override parent's specification, but typically only
    # defined in the root view.
    #
    # This attribute must be defined in the view or its parents.
    _assert_value(view_class_map => $map_name);
    _die("$map_name: not a valid view_class_map;"
        .' check Bivio::IO::ClassLoader configuration'
    ) unless Bivio::IO::ClassLoader->is_map_configured($map_name);
    _put(view_class_map => $map_name);
    return;
}

sub view_declare {
    my($proto, @args) = _args(@_);
    # Defines existence of I<attr_name>s on view.  This is equivalent to
    # calling L<view_put|"view_put"> on the I<attr_name>s with valus
    # of C<undef>.
    return $proto->view_put(map {($_, undef)} @args);
}

sub view_get {
    my(undef, $attr) = _args(@_);
    # Returns the attribute from the current view.  You probably want to use
    # L<view_widget_value|"view_widget_value"> for values in widgets.  This routine
    # is used for more complex widget value accesses.
    #
    # This works during evaluation of a view as well as during execution.
    return ($_VIEW_IN_EVAL
	|| Bivio::Agent::Request->get_current->get('Bivio::UI::View'))
	->ancestral_get($attr);
}

sub view_main {
    my($proto, $widget) = _args(@_);
    # Specifies the "main" widget for this view.  This widget will be rendered when
    # the view or its children are executed.
    #
    # A view must either have a L<view_parent|"view_parent"> or a view_main.
    _assert_value('view_main', $widget,
	    qw(Bivio::UI::Widget execute render));
    _put(view_main => $widget);
    return;
}

sub view_ok {
    # Returns true if in eval.
    return $_VIEW_IN_EVAL
	|| UNIVERSAL::isa('Bivio::UI::View', 'Bivio::UNIVERSAL')
	&& Bivio::UI::View->unsafe_get_current ? 1 : 0;
}

sub view_parent {
    my($proto, $view_name) = _args(@_);
    # A view may be the child of another view.  Child views inherit attributes from
    # their parents.  Child views may override their ancestors' attributes.  A view
    # without a view_parent is called a I<root view>.
    #
    # A view must either have a L<view_main|"view_main"> or a view_parent.
    _assert_value('view_parent', $view_name);
    _assert_in_eval('view_parent')->internal_set_parent($view_name);
    return;
}

sub view_pre_execute {
    my($proto, $code) = _args(@_);
    # Code to be executed prior to rendering the view.
    _die('view_pre_execute must be a code_ref') unless ref($code) eq 'CODE';
    _put(view_pre_execute => $code);
    return;
}

sub view_put {
    # Sets (I<attr_name>, I<attr_value>) attributes.
    #
    # I<attr_name>s must not already exist, must be perl identifiers
    # beginning with a letter, must be all lower case,
    # and may not begin with I<view_>.
    _validated_put(\@_, 0);
    return;
}

sub view_shortcuts {
    my($proto, $class_name) = _args(@_);
    # Shortcuts are application specific functions available to view programs.  A
    # view defines the class which implements these shortcuts.  If no shortcuts are
    # used, this attribute need not be defined.
    #
    # I<class_name> defines the shortcuts.  I<class_name> must be a subclass
    # L<Bivio::UI::ViewShortcutsBase|Bivio::UI::ViewShortcutsBase>.
    #
    # Shortcuts begin with the prefix C<vs_>.  This ensures the names of shortcuts do
    # not conflict with perl's internal names, the ViewLanguage functions (which always
    # begin with C<view_>), or names of widgets (which are always begin with an upper
    # case letter and are simple class names).
    _assert_value('view_shortcuts', $class_name,
	    'Bivio::UI::ViewShortcutsBase');
    _put(view_shortcuts => $class_name);
    return;
}

sub view_unsafe_put {
    # Sets (I<attr_name>, I<attr_value>) attributes.
    #
    # I<attr_name>s may already exist, but must follow view_put's syntax.
    _validated_put(\@_, 1);
    return;
}

sub view_use {
    my($proto, $class) = _args(@_);
    # Calls I<use> with I<class> which may be a map.class or a package::name.
    return $proto->use($class);
}

sub view_widget_value {
    my(undef, $attr) = _args(@_);
    # Returns a widget value which retrieves a L<Bivio::UI::View|Bivio::UI::View>
    # attribute from the view at render time.  Used by parent views to retrieve
    # attributes from their children at run-time.
    my($view) = _assert_in_eval('view_widget_value');
    _die($attr.': attribute not found; view or its parents must declare'
	    .' before use')
	    unless $view->ancestral_has_keys($attr);
    return [['->get_request'], 'Bivio::UI::View', '->ancestral_get', $attr];
}

sub _args {
    # Detects if first argument is $proto or not.  When view_*() methods
    # are called from view files or templates, they are not given a $proto.
    return defined($_[0]) && $_[0] eq __PACKAGE__ ? @_ : (__PACKAGE__, @_);
}

sub _assert_in_eval {
    my($op) = @_;
    # Returns the current view or terminates.
    my($res) = _in_eval();
    return $res
	if $res;
    $op ||= 'eval';
    $op =~ s/.*:://;
    Bivio::Die->die($op, ': operation only allowed in views');
    # DOES NOT RETURN
}

sub _assert_value {
    my($name, $value, $class, @methods) = @_;
    # Asserts value is defined, isa class, and implements methods.
    _die("$name() not supplied a value") unless defined($value);
    return unless $class;

    # Load class and value class unless is ref (loaded)
    unless (ref($value)) {
	Bivio::IO::ClassLoader->simple_require($class);
	Bivio::IO::ClassLoader->simple_require($value);
    }
    _die(": $name()'s value not a $class")
	    unless UNIVERSAL::isa($value, $class);

    foreach my $m (@methods) {
	_die($value, qq{: $name() does not implement $m})
	    unless $value->can($m);
    }
    return;
}

sub _die {
    # Calls _assert_in_eval()->compile_die($msg).
    _assert_in_eval()->compile_die(@_);
    # DOES NOT RETURN
}

sub _eval_code {
    my($code) = @_;
    # Evaluates a sequence of code in this class's context.
    my($copy) = 'use strict;' . $$code;
    _trace($copy) if $_TRACE;
    return Bivio::Die->eval_or_die(\$copy);
}

sub _eval_view {
    my($view) = @_;
    # Does view version of eval.
    $view->compile_die('view already compiled!')
	if $view->is_read_only;
    local($_VIEW_IN_EVAL) = $view;
    return Bivio::Die->catch(sub {
	my($code) = $view->compile;
	_eval_code($code)
	    if ref($code) eq 'SCALAR';
	_initialize($view);
	return;
    });
}

sub _in_eval {
    return $_VIEW_IN_EVAL || Bivio::UI::View->unsafe_get_current;
}

sub _initialize {
    my($view) = @_;
    # Ensures the attributes are properly defined.  Specifies refs
    # with no uses.
    my($values) = $view->get_shallow_copy;
    while (my($k, $v) = each(%$values)) {
	$v->put_and_initialize(parent => undef)
	    if __PACKAGE__->is_blessed($v, 'Bivio::UI::Widget');
    }
    _die('view_main or view_parent must be specified')
	unless $view->has_keys('view_main') || $view->has_keys('view_parent');
#TODO: Traverse parents to see if all attributes defined
    $view->put(view_is_executable => 1);
    $view->set_read_only;
    return;
}

sub _put {
    my($name, $value, $overwrite) = @_;
    # Asserts in eval and puts the attribute.  Cannot be called twice.
    my($view) = _assert_in_eval();
    # We allow an attribute to be view_declared (undef) and then
    # assigned later in the view.
    _die($name, ': view attribute already defined in this view',
	 ' (no overrides within view)')
	unless $overwrite || !defined($view->unsafe_get($name));
    $view->put($name => $value);
    return;
}

sub _validated_put {
    my($args, $overwrite) = @_;
    my($proto, @args) = _args(@$args);
    _die('view_put not supplied any arguments')
	unless @args > 1;
    _die('view_put not supplied an even number of arguments')
	    if @args % 2 != 0;
    $proto->map_by_two(sub {
	my($n, $v) = @_;
	# The syntax is very rigid to allow for expansion
	_die($n, ': attr_name is not a perl identifier')
	    if $n =~ /\W/;
	_die($n, ': attr_name does not begin with a letter')
	    unless $n =~ /^[a-z]/;
	_die($n, ': attr_name is not all lower case')
	    if $n =~ /[A-Z]/;
	_die($n, ': attr_name may not begin with view_')
	    if $n =~ /^view_/;
	_die($n, ': is a reserved attribute name')
	    if $n eq 'parent';
	_put($n, $v, $overwrite);
	return;
    }, \@args);
    return;
}

1;
