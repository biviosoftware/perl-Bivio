# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::ClassLoader;
use strict;
$Bivio::IO::ClassLoader::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::ClassLoader::VERSION;

=head1 NAME

Bivio::IO::ClassLoader - implements dynamic class loading

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::ClassLoader;
    Bivio::IO::ClassLoader->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::ClassLoader::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::ClassLoader> implements dynamic class loading.
L<simple_require|"simple_require"> implements a dynamic C<use> clause.

L<map_require|"map_require"> is an indirect load via mapped name.  The classes
loaded have names of the form I<Map>.I<Class>.  The I<map> is a simple perl
identifier which identifies a class path or handler class which does the
loading.  map_require calls simple_require if the I<map_class> is a
simple class.

L<delegate_require|"delegate_require"> is called by classes which delegate
(part of) their implementations.  A I<delegate> may provide I<info>, a data
structure which defines the internals of, say, a
L<Bivio::Type::Enum|Bivio::Type::Enum>.  A delegate may also completely
implement the class.

=cut

=head1 CONSTANTS

=cut

=for html <a name="MAP_SEPARATOR"></a>

=head2 MAP_SEPARATOR : string

Returns the separator character (.)

=cut

sub MAP_SEPARATOR {
    return '.';
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;

#=VARIABLES
our($_TRACE);
# Bivio::Die can't be loaded at startup, but it can be loaded before
# the first *_require.  We load it dynamically, because Bivio::Type
# imports this class and Bivio::DieCode is a Type.
#
# map_class -> class name.  If map_class was loaded by handler, then
# it is defined, but undef.  See was_loaded().
my($_MAP_CLASS) = {};
my($_SIMPLE_CLASS) = {};
my($_SEP) = MAP_SEPARATOR();
Bivio::IO::Config->register(my $_CFG = {
    maps => Bivio::IO::Config->REQUIRED,
    delegates => Bivio::IO::Config->REQUIRED,
});

=head1 METHODS

=cut

=for html <a name="delegate_require"></a>

=head2 delegate_require(string class) : Bivio::UNIVERSAL

Returns the delegate for the specified class.

=cut

sub delegate_require {
    my($proto, $class) = @_;
    return $proto->simple_require($_CFG->{delegates}->{$class}
	|| _die($class, ': delegates not configured'));
}

=for html <a name="delegate_require_info"></a>

=head2 delegate_require_info(string class) : any

Returns the class specific delegate information. The delegate should
define L<get_delegate_info|"get_delegate_info">.

=cut

sub delegate_require_info {
    return shift->delegate_require(shift)->get_delegate_info;
}

=for html <a name="delete_require"></a>

=head2 static delete_require(string pkg)

Clears the state of I<pkg> (which must be a fully qualified class)
so that it can be reloaded.

=cut

sub delete_require {
    my(undef, $pkg) = @_;

    delete($_SIMPLE_CLASS->{$pkg});
    while (my($k, $v) = each(%$_MAP_CLASS)) {
	delete($_MAP_CLASS->{$k})
	    if $v eq $pkg;
    }
    delete($INC{_file($pkg)});

    # clear entries in package hash
    no strict 'refs';
    *{"${pkg}::"} = {};

    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item maps : hash_ref []

A map is a named path, e.g.

   AccountScraper => ['Bivio::Data::AccountScraper'],

A class path is a list (array_ref)
of module prefixes to insert in front of the simple class names to load.

=item delegates : hash_ref []

A map of class names to delegate class names.

=back

=cut

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG = {
	%$cfg,
	maps => {map(
	    _map_init($_, $cfg->{maps}->{$_}), keys(%{$cfg->{maps}}),
	)},
    };
    return;
}

=for html <a name="is_map_configured"></a>

=head2 static is_map_configured(string map_name) : boolean

Returns true if I<map_name> exists.

=cut

sub is_map_configured {
    my(undef, $map_name) = @_;
    return $_CFG->{maps}->{$map_name} ? 1 : 0;
}

=for html <a name="map_require"></a>

=head2 static map_require(string map_class) : string

=head2 static map_require(string class_name) : string

=head2 static map_require(string map_name, string class_name) : string

Returns the fully qualified class loaded.

A I<map_class> is of the form:

    map_name.class_name

Throws an exception if the class can't be found or doesn't load.

If I<class_name> is passed without a I<map_name> or if I<class_name>
is a qualified class name (contains ::), the class will be loaded
with L<simple_require|"simple_require">.

=cut

sub map_require {
    my($proto) = shift;
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

=for html <a name="map_require_all"></a>

=head2 static map_require_all(string map_name) : array_ref

=head2 static map_require_all(string map_name, code_ref filter) : array_ref

Discovers and loads all classes in I<map_name> by searching in
C<@INC>.

I<filter> is optional.  I<filter> is called with:

    $filter->($class, $file_name)

where I<class> is the fully qualified perl class name and I<file_name>
is the absolute path name to the class.

If I<filter> returns true, the class will be loaded with
L<map_require|"map_require">.  Otherwise, no action is taken.
See L<Bivio::Biz::Model|Bivio::Biz::Model> for an example.

Returns the names of the classes loaded.

=cut

sub map_require_all {
    my($proto, $map_name, $filter) = @_;
    my($seen) = {};
    return [map(
	map({
	    my($c) = $proto->map_require($map_name, ($_->[0] =~ /(\w+)$/)[0]);
	    $seen->{$c}++ ? () : $c;
	}
            grep(!$filter || $filter->(@$_), _map_glob($map_name, $_)),
	),
	@{$_CFG->{maps}->{$map_name} || _die($map_name, ': no such map')},
    )];
}

=for html <a name="simple_require"></a>

=head2 static simple_require(string package, ...) : array

Loads the packages and throws an exception if any one couldn't be loaded.
I<package> must be a fully-qualified perl package name.

Returns its first argument in scalar context. Else returns all of its
arguments.

=cut

sub simple_require {
    my($proto, @package) = @_;
    my(@res) = map(_require($proto, $_, 1), @package);
    return wantarray ? @res : $res[0];
}

=for html <a name="unsafe_map_require"></a>

=head2 static unsafe_map_require(string map_class) : string

=head2 static unsafe_map_require(string class_name) : string

=head2 static unsafe_map_require(string map_name, string class_name) : string

Returns the fully qualified class loaded.

A I<map_class> is of the form:

    map_name.class_name

Throws an exception if the class doesn't load properly.  Returns C<undef>
if the file can't be found.

If I<class_name> is passed without a I<map_name> or if I<class_name>
is a qualified class name (contains ::), the class will be loaded
with L<unsafe_simple_require|"unsafe_simple_require">.

=cut

sub unsafe_map_require {
    my($proto, $map_name, $class_name, $map_class) = _map_args(@_);
    return $proto->unsafe_simple_require($class_name)
	unless defined($map_name);
    _trace('cached map_class=', $map_class)
	if $_TRACE && $_MAP_CLASS->{$map_class};
    return $_MAP_CLASS->{$map_class}
	if $_MAP_CLASS->{$map_class};
    _trace('map_class=', $map_class)
	if $_TRACE;
    my($map) = $_CFG->{maps}->{$map_name} || _die($map_name, ': no such map');
    foreach my $path (@$map) {
	if (my $x = _require($proto, "$path\::$class_name")) {
	    return $_MAP_CLASS->{$map_class} = $x;
	}
    }
    return undef;
}

=for html <a name="unsafe_simple_require"></a>

=head2 static unsafe_simple_require(string package) : string

Returns I<package> if it could be loaded.  Else, returns C<undef>.

=cut

sub unsafe_simple_require {
    my($proto, $package) = @_;
    return _require($proto, $package);
}

=for html <a name="was_required"></a>

=head2 static was_required(string simple_class) : boolean

=head2 static was_required(string map_class) : boolean

Returns true if I<simple_class> has been loaded into the perl interpreter
or if I<map_class> has been loaded by I<map_require>.

Returns false if class is not loaded or if class isn't a
L<Bivio::UNIVERSAL|Bivio::UNIVERSAL>.

=cut

sub was_required {
    my($proto, $class) = @_;
    return ($class =~ /\Q$_SEP/o ? $_MAP_CLASS->{$class}
        : $_SIMPLE_CLASS->{$class} || UNIVERSAL::isa($class, 'Bivio::UNIVERSAL')
    ) ? 1 : 0;
}

#=PRIVATE METHODS

sub _catch {
    eval('require Bivio::Die;') || die("$@")
	unless UNIVERSAL::can('Bivio::Die', 'catch');
    return Bivio::Die->catch(@_);
}

sub _die {
    Bivio::IO::Alert->bootstrap_die(@_);
}

sub _file {
    my($pkg) = shift(@_) . '.pm';
    $pkg =~ s!::!/!g;
    return $pkg;
}

sub _map_args {
    my($proto, $map_name, $class_name) = @_;
    return ($class_name || $map_name) =~ /^(\w+::)+\w+$/
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
	_map_glob($map_name, $_) ? $_
	    : _die($_, ': empty path in map ', $map_name),
	@$paths,
    )];
}

sub _require {
    my($proto, $pkg, $die_if_not_found) = @_;
    return $pkg
	if UNIVERSAL::isa($pkg, 'Bivio::UNIVERSAL') || $_SIMPLE_CLASS->{$pkg};
    _die($pkg, ': invalid class name')
	unless $pkg =~ /^(\w+::)*\w+$/;
    my($file) = _file($pkg);
    foreach my $i (@INC) {
	return _require_eval($proto, $pkg)
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
	local(\$_);
	# require can't be in "strict refs" mode
	no strict 'refs';
	# Must be a "bareword" for require so perl does '::' substitution
        require $pkg;
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
    _trace($pkg) if $_TRACE;
    $_SIMPLE_CLASS->{$pkg}++;
    return $pkg;
}

=head1 COPYRIGHT

Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
