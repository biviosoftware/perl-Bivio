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

C<Bivio::IO::ClassLoader> implements dynamic class loading.  There
are two forms: fully qualified (L<simple_require|"simple_require">)
and configurable.

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
my(%_PACKAGES);
my(%_MAP_CLASS);
my($_DELEGATES);
my($_MAPS);
my($_MODELS);
my($_SEP) = MAP_SEPARATOR();
Bivio::IO::Config->register({
    maps => {
	AccountScraper => ['Bivio::Data::AccountScraper'],
	Model => ['Bivio::Biz::Model'],
    },
    delegates => {
	'Bivio::Agent::TaskId' => 'Bivio::Agent::TaskIdDelegate',
    },
});

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item maps : hash_ref []

A map is a named path, e.g.

   AccountScraper => ['Bivio::Data::AccountScraper'],

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
	Bivio::IO::Alert->die('map ', $k, ' not an array_ref: ', $v)
		    unless ref($v) eq 'ARRAY';
	$_MAPS->{$k} = [map {
	    my($x) = $_;
	    $x =~ s/(?<!::)$/::/;
	    Bivio::IO::Alert->die('map ', $k, ' path invalid: ', $_)
			unless $x =~ /^(\w+::)+$/;
	    my($dir) = $x;
	    $dir =~ s,::,/,g;
	    my($ok);
	    foreach my $inc (@INC) {
		next unless -d $inc.'/'.$dir;
		$ok = 1;
		last;
	    }
	    Bivio::IO::Alert->die('map ', $k, ' path not found: ', $_)
			unless $ok;
	    $x;
	} @$v];
    }
    my($model_path) = $cfg->{maps}->{'Model'};
    _find_property_models($model_path) if $model_path;
    $_DELEGATES = $cfg->{delegates};
    return;
}

=for html <a name="map_require"></a>

=head2 static map_require(string map, string simple_package_name) : string

=head2 static map_require(string map_class) : string

Returns the fully qualified I<class> from I<map> for the
I<simple_package_name> or from the I<map_class>, which is
of the form:

    map#simple_package_name

Throws an exception if the class can't be found or doesn't load.

=cut

sub map_require {
    my($proto, $map, $simple_package_name, $map_class) = _map_args(@_);
    return $_MAP_CLASS{$map_class} if $_MAP_CLASS{$map_class};

    Bivio::IO::Alert->die($map, ': no such map') unless $_MAPS->{$map};

    my($last_real_error);
    foreach my $path (@{$_MAPS->{$map}}) {
	return $_MAP_CLASS{$map_class} = $path.$simple_package_name
		if _require($path.$simple_package_name);
	$last_real_error = $@
		unless defined($last_real_error) && $@ =~ /^Can't locate/i;
    }
    Bivio::IO::Alert->die($map_class, ': ', defined($last_real_error)
	    ? $last_real_error
	    : 'no paths in map');
    # DOES NOT RETURN
}

=for html <a name="require_delegate"></a>

=head2 require_delegate(string class) : Bivio::UNIVERSAL

Returns the delegate for the specified class.

=cut

sub require_delegate {
    my($proto, $class) = @_;
    my($module) = $_DELEGATES->{$class};
    Bivio::IO::Alert->die('no delegate found for ', $class) unless $module;
    $proto->simple_require($module);
    return $module;
}

=for html <a name="require_delegate_info"></a>

=head2 require_delegate_info(string class) : any

Returns the class specific delegate information. The delegate should
define L<get_delegate_info|"get_delegate_info">.

=cut

sub require_delegate_info {
    my($proto, $class) = @_;
    return $proto->require_delegate($class)->get_delegate_info;
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

=head2 static simple_require(string package, ...)

Loads the packages and throws an exception if any one couldn't be loaded.
I<package> must be a fully-qualified perl package name.

=cut

sub simple_require {
    my($proto, @pkg) = @_;
    foreach my $pkg (@pkg) {
	die('undefined package') unless $pkg;
	_require($pkg) || die($@);
    }
    return;
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

# _map_args(any proto, string map, string simple_package_name) : array
# _map_args(any proto, string map_class) : array
#
# Splits the $map_class if simple_package_name is not defined.
# Returns ($proto, $map, $simple_package_name, $map_class).
#
sub _map_args {
    my($proto, $map, $simple_package_name) = @_;
    return ($proto, $map, $simple_package_name,
	    $map.$_SEP.$simple_package_name) if $simple_package_name;
    Bivio::IO::Alert->die('invalid map_class: ', $map)
		unless $map =~ /^(\w+)#(\w+)$/;
    return ($proto, $1, $2, $map);
}

# _require(string pkg) : boolean
#
# Returns true if the package could be required.
#
sub _require {
    my($pkg) = @_;

    # Avoid problems with uses of $_ in $pkg
    local($_);

    # This avoids problems with Bivio::Die
    local($SIG{__DIE__});

    no strict 'refs';
    # We use our own symbol table, because there is a weird case
    # with enums which define the package symbol table in advance
    # of loading. In other words, this doesn't work:
    #    next if defined(%{*{"$pkg\::"}});
    return 1 if defined($_PACKAGES{$pkg});

    # Must be a "bareword" for it to do '::' substitution
    return 0 unless eval("require $pkg");
    _trace($pkg) if $_TRACE;

    # Only define if loads properly.
    return $_PACKAGES{$pkg} = 1;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
