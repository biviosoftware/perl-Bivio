# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::ClassLoader;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::Config;
use Bivio::IO::Alert;
use Bivio::IO::Trace;

# C<Bivio::IO::ClassLoader> implements dynamic class loading.
# L<simple_require|"simple_require"> implements a dynamic C<use> clause.
#
# L<map_require|"map_require"> is an indirect load via mapped name.  The classes
# loaded have names of the form I<Map>.I<Class>.  The I<map> is a simple perl
# identifier which identifies a class path or handler class which does the
# loading.  map_require calls simple_require if the I<map_class> is a
# simple class.
#
# L<delegate_require|"delegate_require"> is called by classes which delegate
# (part of) their implementations.  A I<delegate> may provide I<info>, a data
# structure which defines the internals of, say, a
# L<Bivio::Type::Enum|Bivio::Type::Enum>.  A delegate may also completely
# implement the class.

our($_TRACE);
# Bivio::Die can't be loaded at startup, but it can be loaded before
# the first *_require.  We load it dynamically, because Bivio::Type
# imports this class and Bivio::DieCode is a Type.
#
# map_class -> class name.  If map_class was loaded by handler, then
# it is defined, but undef.  See was_loaded().
my($_MAP_CLASS) = {};
my($_SIMPLE_CLASS) = {};
my($_SEP) = __PACKAGE__->MAP_SEPARATOR;
Bivio::IO::Config->register(my $_CFG = {
    maps => Bivio::IO::Config->REQUIRED,
    delegates => Bivio::IO::Config->REQUIRED,
});

sub MAP_SEPARATOR {
    # Returns the separator character (.)
    return '.';
}

sub after_in_map {
    my($proto, $map_name, $this_package) = @_;
    my($class) = $this_package =~ /(\w+)$/;
    my($found) = 0;
    foreach my $path (_map_path_list($map_name)) {
	my($pkg) = "$path\::$class";
	if ($this_package eq $pkg) {
	    $found = 1;
	    next;
	}
	next unless $found;
	my($file) = _file($pkg);
	foreach my $i (@INC) {
	    return $pkg
		if -r "$i/$file";
	}
    }
    _die($map_name, ': unable to find package after ', $this_package);
    # DOES NOT RETURN
}

sub all_map_names {
    return [sort(keys(%{$_CFG->{maps}}))];
}

sub call_autoload {
    my($proto, $autoload, $args, $no_match) = @_;
    my($func) = $autoload;
    $func =~ s/.*:://;
    return
	if $func eq 'DESTROY';
    my($map, $class)
	= $func =~ /^([A-Z][a-zA-Z0-9_]+)_([A-Z][A-Za-z0-9]+)$/;
    if ($map) {
	_die($autoload, ': no such mapped class')
	    unless $proto->is_map_configured($map)
	    and $class = $proto->unsafe_map_require($map, $class);
    }
    elsif ($no_match) {
	return $no_match->($func, $args)
	    if ref($no_match) eq 'CODE';
	foreach my $m (@$no_match) {
	    next
		unless $class = $proto->unsafe_map_require($m, $func);
	    $map = $m;
	    last;
	}
    }
    _die($autoload, ': method not found')
	unless $class;
    return $class->handle_call_autoload(@$args)
	if $class->can('handle_call_autoload');
    return $class->new(@$args)
	if @$args;
    return $class;
}

sub delegate_get_map_entry {
    my(undef, $delegator) = @_;
    return $_CFG->{delegates}->{$delegator}
	    || _die($delegator, ': delegate not configured'),    
}

sub delegate_replace_map_entry {
    my($proto, $delegator, $delegate) = @_;
    $_CFG->{delegates}->{$delegator->package_name} = $delegate;
    return;
}

sub delegate_require {
    my($proto, $delegator) = @_;
    return $proto->simple_require($proto->delegate_get_map_entry($delegator));
}

sub delete_require {
    my(undef, $pkg) = @_;
    _pre_delete_require($pkg);
    while (my($k, $v) = each(%$_MAP_CLASS)) {
	delete($_MAP_CLASS->{$k})
	    if $v eq $pkg;
    }
    delete($INC{_file($pkg)});
    no strict 'refs';
    undef(*{"${pkg}::"});
    return;
}

sub handle_config {
    my($proto, $cfg) = @_;
    # maps : hash_ref []
    #
    # A map is a named path, e.g.
    #
    #    AccountScraper => ['Bivio::Data::AccountScraper'],
    #
    # A class path is a list (array_ref)
    # of module prefixes to insert in front of the simple class names to load.
    #
    # delegates : hash_ref []
    #
    # A map of class names to delegate class names.
    $_CFG = {
	%$cfg,
	maps => {map(
	    _map_init($_, $cfg->{maps}->{$_}), keys(%{$cfg->{maps}}),
	)},
    };
    return;
}

sub is_map_configured {
    my(undef, $map_name) = @_;
    # Returns true if I<map_name> exists.
    return $_CFG->{maps}->{$map_name} ? 1 : 0;
}

sub is_valid_map_class_name {
    my($self, $class) = @_;
    return $class =~ /^\w+\.\w+$/ ? 1 : 0;
}

sub list_simple_packages_in_map {
    my($proto, $map_name, $filter) = @_;
    my($seen) = {};
    return [sort(
	map(
	    map({
		my($c) = $_->[0] =~ /(\w+)$/;
		$seen->{$c}++ ? () : $c;
	    } grep(!$filter || $filter->(@$_), _map_glob($map_name, $_))),
	    _map_path_list($map_name),
	),
    )];
}

sub map_require {
    my($proto) = shift;
    # Returns the fully qualified class loaded.
    #
    # A I<map_class> is of the form:
    #
    #     map_name.class_name
    #
    # Throws an exception if the class can't be found or doesn't load.
    #
    # If I<class_name> is passed without a I<map_name> or if I<class_name>
    # is a qualified class name (contains ::), the class will be loaded
    # with L<simple_require|"simple_require">.
    my($res) = $proto->unsafe_map_require(@_);
    return $res
	if $res;
    my(undef, $map_name, $class_name, $map_class) = _map_args($proto, @_);
    _die(NOT_FOUND => {
	message => 'class not found',
	entity => $map_class || $class_name,
    });
    # DOES NOT RETURN
}

sub map_require_all {
    my($proto, $map_name) = (shift, shift);
    # Discovers and loads all classes in I<map_name> by searching in
    # C<@INC>.
    #
    # I<filter> is optional.  I<filter> is called with:
    #
    #     $filter->($class, $file_name)
    #
    # where I<class> is the fully qualified perl class name and I<file_name>
    # is the absolute path name to the class.
    #
    # If I<filter> returns true, the class will be loaded with
    # L<map_require|"map_require">.  Otherwise, no action is taken.
    # See L<Bivio::Biz::Model|Bivio::Biz::Model> for an example.
    #
    # Returns the names of the classes loaded.
    return [
	map(
	    $proto->map_require($map_name, $_),
	   @{$proto->list_simple_packages_in_map($map_name, @_)},
	),
    ];
}

sub require_external_module_quietly {
    my(undef, $module) = @_;
    _die("$module: $@\n")
	unless Bivio::Die->eval("use strict; use $module (); 1;");
    return;
}

sub simple_require {
    my($proto, @package) = @_;
    # Loads the packages and throws an exception if any one couldn't be loaded.
    # I<package> must be a fully-qualified perl package name.
    #
    # Returns its first argument in scalar context. Else returns all of its
    # arguments.
    my(@res) = map(_require($proto, $_, 1), @package);
    return wantarray ? @res : $res[0];
}

sub unsafe_map_for_package {
    my($self, $package) = @_;
    foreach my $map_name (@{$self->all_map_names}) {
	foreach my $path (_map_path_list($map_name)) {
	    return $map_name
		if $package =~ /^\Q$path\E::\w+$/;
	}
    }
    return undef;
}

sub unsafe_map_require {
    my($proto, $map_name, $class_name, $map_class) = _map_args(@_);
    # Returns the fully qualified class loaded.
    #
    # A I<map_class> is of the form:
    #
    #     map_name.class_name
    #
    # Throws an exception if the class doesn't load properly.  Returns C<undef>
    # if the file can't be found.
    #
    # If I<class_name> is passed without a I<map_name> or if I<class_name>
    # is a qualified class name (contains ::), the class will be loaded
    # with L<unsafe_simple_require|"unsafe_simple_require">.
    #
    # COUPLING: Bivio::Base::b_use assumes it can cache responses.
    #           This means _post_require is only called once per
    #		(importer, map_class) name.
    return $proto->unsafe_simple_require($class_name)
	unless defined($map_name);
    return _post_require($_MAP_CLASS->{$map_class})
	if $_MAP_CLASS->{$map_class};
    _trace($map_class) if $_TRACE;
    foreach my $path (_map_path_list($map_name)) {
	my($try) = $path . '::' . $class_name;
	$_MAP_CLASS->{$map_class} = $try;
	my($die) = _catch(sub {$try = _require($proto, $try)});
	return $try
	    if $try && !$die;
	delete($_MAP_CLASS->{$map_class});
	$die->throw
	    if $die;
    }
    return undef;
}

sub unsafe_required_class {
    my(undef, $class) = @_;
    return $_MAP_CLASS->{$class}
	if $class =~ /\Q$_SEP/o;
    return $_SIMPLE_CLASS->{$class}
	|| (Bivio::UNIVERSAL->is_super_of($class) ? $class : undef);
}

sub unsafe_simple_require {
    my($proto, $package) = @_;
    return _require($proto, $package);
}

sub was_required {
    my($proto, $class) = @_;
    return shift->unsafe_required_class(@_) ? 1 : 0;
}

sub _catch {
    eval('require Bivio::Die;') || die("$@")
	unless UNIVERSAL::can('Bivio::Die', 'catch');
    return Bivio::Die->catch(@_);
}

sub _die {
    Bivio::IO::Alert->bootstrap_die(@_);
    # DOES NOT RETURN
}

sub _file {
    my($pkg) = shift(@_) . '.pm';
    $pkg =~ s!::!/!g;
    return $pkg;
}

sub _importing_pkg {
    foreach my $depth (2..20) {
	last
	    unless my $pkg = (caller($depth))[0];
	return $pkg
	    unless $pkg
	    =~ /^(?:Bivio::Die|Bivio::Base|Bivio::UNIVERSAL|Bivio::IO::ClassLoader)$/;
    }
    return 'main';
}

sub _map_args {
    my($proto, $map_name, $class_name) = @_;
    return ($class_name || $map_name) =~ /::/
	? ($proto, undef, $class_name || $map_name, undef)
	: $map_name && $class_name
        ? ($proto, $map_name, $class_name, "$map_name$_SEP$class_name")
	: $map_name =~ /^(\w+)\Q$_SEP\E(\S+)$/o
	? ($proto, $1, $2, $map_name)
	: _die('invalid arguments: ', \@_);
}

sub _map_glob {
    my($map_name, $path) = @_;
    _die($path, ': invalid path in map ', $map_name)
	unless $path =~ /^(?:\w+::)*\w+$/;
    my($pat) = _file("$path\::*");
    return map(
	map(["$path\::" . ($_ =~ /(\w+)\.pm/)[0], $_], glob("$_/$pat")),
	@INC,
    );
}

sub _map_init {
    my($map_name, $paths) = @_;
    return $map_name => [map(
	_map_glob($map_name, $_) ? $_ : (),
	@$paths,
    )];
}

sub _map_path_list {
    my($name) = @_;
    return @{$_CFG->{maps}->{$name} || _die($name, ': no such map')};
}

sub _pre_delete_require {
    my($pkg) = @_;
    return
	unless my $importers = delete($_SIMPLE_CLASS->{$pkg});
    $pkg->handle_class_loader_delete_require($importers)
	if defined(&{"${pkg}::handle_class_loader_delete_require"});
    return;
}

sub _post_require {
    my($pkg) = @_;
    $_SIMPLE_CLASS->{$pkg} ||= {};
    if (defined(&{"${pkg}::handle_class_loader_require"})) {
	my($ip) = _importing_pkg();
	$pkg->handle_class_loader_require($ip)
	    unless $_SIMPLE_CLASS->{$pkg}->{$ip}++;
    }
    return $pkg;
}

sub _require {
    my($proto, $pkg, $die_if_not_found) = @_;
    return _post_require($pkg)
	if $proto->was_required($pkg);
    _die($pkg, ': invalid class name')
	unless $pkg =~ /^(\w+::)*\w+$/;
    my($file) = _file($pkg);
    foreach my $i (@INC) {
	return _post_require(_require_eval($proto, $pkg))
	    if -r "$i/$file";
    }
    _die(NOT_FOUND => {
	message => 'class file not found',
	INC => [@INC],
	entity => $file,
    }) if $die_if_not_found;
    return undef;
}

sub _require_eval {
    my($proto, $pkg) = @_;
    local($_);
    my($code) = <<"EOF";
    {
        package @{[_importing_pkg()]};
	local(\$_);
        require $pkg;
        1;
    }
EOF
    # Using \$code keeps the stack trace clean
    my($die) = _catch(\$code);
    if ($die) {
	# Perl does not clear the state associated with the $pkg so
	# we have to do it manually.
	$proto->delete_require($pkg);
	$die->throw;
	# DOES NOT RETURN
    }
    _trace(_importing_pkg(), ' requires ', $pkg) if $_TRACE;
    return $pkg;
}

1;
