# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::IO::ClassLoader;
use strict;
$Bivio::IO::ClassLoader::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::ClassLoader::VERSION;

=head1 NAME

Bivio::IO::ClassLoader - implements dynamic class loading

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
loaded have names of the form I<Map>#I<Class>.  The I<map> is a simple perl
identifier which identifies a class path or handler class which does the
loading.  map_require calls simple_require if the I<map_class> is a
simple class.

L<delegate_require|"delegate_require"> is called by classes which delegate
(part of) their implementations.  A I<delegate> may provide I<info>, a data
structure which defines the internals of, say, a
L<Bivio::Type::Enum|Bivio::Type::Enum>.  A delegate may also completely
implement the class.

B<NOTE: You can only load classes which are of type
L<Bivio::UNIVERSAL|Bivio::UNIVERSAL> with this module.>

=cut

=head1 CONSTANTS

=cut

=for html <a name="MAP_SEPARATOR"></a>

=head2 MAP_SEPARATOR : string

Returns the separator character (#)

=cut

sub MAP_SEPARATOR {
    return '#';
}

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::IO::Config;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# map_class -> class name.  If map_class was loaded by handler, then
# it is defined, but undef.  See is_loaded().
my(%_MAP_CLASS);
my(%_SIMPLE_CLASS);
my($_DELEGATES);
my($_MAPS);
my($_MODELS);
my($_SEP) = MAP_SEPARATOR();
Bivio::IO::Config->register;

=head1 METHODS

=cut

=for html <a name="delegate_require"></a>

=head2 delegate_require(string class) : Bivio::UNIVERSAL

Returns the delegate for the specified class.

=cut

sub delegate_require {
    my($proto, $class) = @_;
    my($module) = $_DELEGATES->{$class};
    Bivio::IO::Alert->die('no delegate found for ', $class) unless $module;
    $proto->simple_require($module);
    return $module;
}

=for html <a name="delegate_require_info"></a>

=head2 delegate_require_info(string class) : any

Returns the class specific delegate information. The delegate should
define L<get_delegate_info|"get_delegate_info">.

=cut

sub delegate_require_info {
    my($proto, $class) = @_;
    return $proto->delegate_require($class)->get_delegate_info;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item maps : hash_ref []

A map is a named path, e.g.

   AccountScraper => ['Bivio::Data::AccountScraper'],
   View => 'Bivio::UI::View',

If a class path is provided (array_ref), ClassLoader does all the work.  It
searches the path specified for the classes in the map's name space.  If a
class (string) is provided, the class is loaded and the method
L<handle_map_require|"handle_map_require"> is called on the class to load the
class.

=item delegates : hash_ref []

A map of class names to delegate class names.

=back

=cut

sub handle_config {
    my($proto, $cfg) = @_;
    Bivio::IO::Alert->die('maps must be a hash_ref')
		unless ref($cfg->{maps}) eq 'HASH';

    # Normalize and validate the map paths
    $_MAPS = {};
    while (my($k, $v) = each(%{$cfg->{maps}})) {
	if (ref($v) eq 'ARRAY') {
	    $_MAPS->{$k} = _map_path_init($k, $v);
	}
	elsif (defined($v) && !ref($v)) {
	    $_MAPS->{$k} = $v;
	}
	else {
	    Bivio::IO::Alert->die('map ', $k,
		    ' not an array_ref or class name: ', $v);
	}
    }
    my($model_path) = $cfg->{maps}->{'Model'};
    _find_property_models($model_path) if $model_path;
    $_DELEGATES = $cfg->{delegates};
    return;
}

=for html <a name="handle_map_require"></a>

=head2 abstract handle_map_require(string map_name, string class_name, string map_class) : UNIVERSAL

Called by L<map_require|"map_require"> in map handle classes.  A handler class
must look up I<class_name> (syntax specific to this I<map_name>) and return the
class or an instance of the class.  I<map_class> is the fully qualified name.

Map handlers are responsible for managing their own cache.  This module
will not cache the result.  It will return true for is_loaded, however.

=cut

$_ = <<'}'; # emacs
sub handle_map_require {
}

=for html <a name="is_loaded"></a>

=head2 static is_loaded(string simple_class) : boolean

=head2 static is_loaded(string map_class) : boolean

Returns true if I<simple_class> has been loaded into the perl interpreter
or if I<map_class> has been loaded by I<map_require>.

Returns false if class is not loaded or if class isn't a
L<Bivio::UNIVERSAL|Bivio::UNIVERSAL>.

=cut

sub is_loaded {
    my($proto, $class) = @_;
    # this seems to work
    return ($class =~ /$_SEP/o ? exists($_MAP_CLASS{$class})
	    : UNIVERSAL::isa($class, 'Bivio::UNIVERSAL')) ? 1 : 0;
}

=for html <a name="is_valid_map"></a>

=head2 static is_valid_map(string map_name) : boolean

Returns true if I<map_name> exists.

=cut

sub is_valid_map {
    my(undef, $map_name) = @_;
    return $_MAPS->{$map_name} ? 1 : 0;
}

=for html <a name="map_require"></a>

=head2 static map_require(string map_class) : UNIVERSAL

=head2 static map_require(string class_name) : UNIVERSAL

=head2 static map_require(string map_name, string class_name) : UNIVERSAL

Returns the fully qualified class or an instance of a class.

A I<map_class> is of the form:

    map_name#class_name

Throws an exception if the class can't be found or doesn't load.  The
syntax of class is map specific.

If I<class_name> is passed without a I<map_name> or if I<class_name>
is a qualified class name (contains ::), the class will be loaded
with L<simple_require|"simple_require">.

=cut

sub map_require {
    my($proto, $map_name, $class_name, $map_class) = _map_args(@_);
    return $proto->simple_require($class_name) unless defined($map_name);

    return $_MAP_CLASS{$map_class} if defined($_MAP_CLASS{$map_class});

    my($map) = $_MAPS->{$map_name};
    Bivio::IO::Alert->die($map_name, ': no such map') unless $map;
    unless (ref($map)) {
	_init_map_handler($map_name, $map) unless $_SIMPLE_CLASS{$map};
	my($res) = $map->handle_map_require(
		$map_name, $class_name, $map_class);
	# Exists, but not defined so above test falls through.
	$_MAP_CLASS{$map_class} = undef;
	return $res;
    }

    my($last_real_error);
    foreach my $path (@$map) {
	return $_MAP_CLASS{$map_class} = $path.$class_name
		if _require($path.$class_name);
	_trace($@) if $_TRACE;
	$last_real_error = $@
		unless defined($last_real_error) && $@ =~ /Can't locate/i;
    }
    Bivio::IO::Alert->die($map_class, ': ', defined($last_real_error)
	    ? $last_real_error
	    : 'no paths in map');
    # DOES NOT RETURN
}

=for html <a name="require_property_models"></a>

=head2 static require_property_models()

Loads all the property model packages, which exist in the I<model_classpath>
directories.

=cut

sub require_property_models {
    my($proto) = @_;
    return unless $_MODELS;

    # make a copy and delete original to prevent reentrant calls
    my(@models) = (@$_MODELS);
    $_MODELS = undef;

    $proto->simple_require('Bivio::Biz::Model');
    foreach my $class (@models) {
	Bivio::Biz::Model->get_instance($class);
    }
    return;
}

=for html <a name="simple_require"></a>

=head2 static simple_require(string package, ...) : array

Loads the packages and throws an exception if any one couldn't be loaded.
I<package> must be a fully-qualified perl package name.

Returns its first argument in scalar context. Else returns all of its
arguments.

=cut

sub simple_require {
    my($proto, @pkg) = @_;
    foreach my $pkg (@pkg) {
	die('undefined package') unless $pkg;
	_require($pkg) || die($@);
    }
    return wantarray ? @pkg : $pkg[0];
}

#=PRIVATE METHODS

# _find_property_models(string classpath)
#
# Finds the full name of the property models. Used later by
# I<require_property_models>.
#
sub _find_property_models {
    my($classpath) = @_;
    $_MODELS = [];

    # first get the base path, using UNIVERSAL
    my($universal) = 'Bivio/UNIVERSAL.pm';
    my($base) = $INC{$universal};
    $base =~ s/$universal//;

    foreach my $package (@$classpath) {
	my($pat) = $package;
	$pat =~ s,::,/,g;
	$pat = $base.$pat.'/*.pm';

	# Find all Models
	foreach my $class (glob($pat)) {
	    $class =~ s,.*/,,;
	    $class =~ s/\.pm//;

	    # only interested in property models, ignore common file names
	    next if $class =~ /Form$/;
	    next if $class =~ /List$/;
	    next if $class =~ /Base$/;

	    push(@$_MODELS, $package.'::'.$class);
	}
    }
    return;
}

# _init_map_handler(string map_name, string map_handler)
#
# Loads the class and ensures is valid.
#
sub _init_map_handler {
    my($map_name, $map_handler) = @_;
    Bivio::IO::Alert->die($map_handler, ': class not found for map ',
	    $map_name) unless _require($map_handler);
    Bivio::IO::Alert->die($map_handler, ': must implement handle_map_require',
	    ' for map ', $map_name)
		unless $map_handler->can('handle_map_require');
    $_SIMPLE_CLASS{$map_handler}++;
    return;
}

# _map_args(any proto, string map_name, string class_name) : array
# _map_args(any proto, string map_class) : array
# _map_args(any proto, string simple_class) : array
#
# Splits the $map_name if class_name is not defined.
# Returns ($proto, $map_name, $class_name, $map_name).
# Returns undef for $map_name if simple class.
#
sub _map_args {
    my($proto, $map_name, $class_name) = @_;
    # ('Bla::bla')
    return ($proto, undef, $map_name, undef)
	    if !defined($class_name) && $map_name =~ /^(\w+::)+\w+$/;

    # ('Type', 'Bla::Bla')
    return ($proto, undef, $class_name, undef)
	    if defined($class_name) && $class_name =~ /^(\w+::)+\w+$/;

    # ('Type', 'Bla')
    return ($proto, $map_name, $class_name, $map_name.$_SEP.$class_name)
	    if $map_name && $class_name;

    # ('Type#Bla')
    return ($proto, $1, $2, $map_name)
	    if $map_name =~ /^(\w+)$_SEP(\S+)$/o;

    Bivio::IO::Alert->die('invalid map_class: ', $map_name);
    # DOES NOT RETURN
}

# _map_path_init(string map_name, array_ref paths) : array_ref
#
# Creates a class path out of $paths.
#
sub _map_path_init {
    my($map_name, $paths) = @_;
    return [map {
	my($x) = $_;
	$x =~ s/(?<!::)$/::/;
	Bivio::IO::Alert->die('map ', $map_name, ' path invalid: ', $_)
		    unless $x =~ /^(\w+::)+$/;
	my($dir) = $x;
	$dir =~ s,::,/,g;
	my($ok);
	foreach my $inc (@INC) {
	    next unless -d $inc.'/'.$dir;
	    $ok = 1;
	    last;
	}
	Bivio::IO::Alert->die('map ', $map_name, ' path not found: ', $_)
		    unless $ok;
	$x;
    } @$paths];
}

# _require(string pkg) : string
#
# Returns true if the package could be required.
#
sub _require {
    my($pkg) = @_;

    # Is this class already loaded?
    return $pkg if UNIVERSAL::isa($pkg, 'Bivio::UNIVERSAL');

    # Avoid problems with uses of $_ in $pkg
    local($_);

    # This avoids problems with Bivio::Die
    local($SIG{__DIE__});

    no strict 'refs';

    # Must be a "bareword" for require to do the '::' substitution
    return undef unless eval("require $pkg");
    _trace($pkg) if $_TRACE;

    Bivio::IO::Alert->die($pkg, ': not a Bivio::UNIVERSAL')
	    unless UNIVERSAL::isa($pkg, 'Bivio::UNIVERSAL');
    $_SIMPLE_CLASS{$pkg}++;

    # Only define if loads properly.
    return $pkg;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
