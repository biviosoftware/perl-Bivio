# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade;
use strict;
$Bivio::UI::Facade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade - determines the outward representation of a set of components

=head1 SYNOPSIS

    use Bivio::UI::Facade;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::UI::Facade::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::UI::Facade> is a collection of instances which present a uniform
view.  Typically, a Facade is used to represent UI components.  An
Facade instance is a collection of attributes.  Most of the attributes
are identified by their components' package names.  There are some
other attributes, e.g. I<clone>, which are defined below.

A Facade components L<register|"register"> with this module, statically.

=head1 ATTRIBUTES

There are two types of attributes: I<facade> and I<component>.
A I<facade> attribute is on the whole Facade.  A I<component>
attribute is configured for the Component.

=over 4

=item clone : Bivio::UI::Facade (facade,component)

The base map for this Facade.  If C<undef>, there is no base.
A component is always instantiated from a clone or as a new instance.
The default I<clone> is on the Facade and must always be specified
(even if C<undef>).  The I<clone> may be overriden in a particular
component's configuration.

=item initialize : sub (component)

The initialization attribute is a C<sub> to initialize a Component.
I<initialize> takes one argument: the Component being initialized.
The component will already have the I<facade> to which it belongs
as an attribute when I<initialize> is called.

=item is_production : boolean (facade)

If set to true, the Facade will be found in a production environment.
Otherwise, won't be initialized if not running in the
production environment.

=item uri : string (facade)

Name of the facade as it appears in domain names and URIs.
The base name of the Facade's package.

=item E<lt>ModuleE<gt> : Bivio::UI::FacadeComponent (facade)

Component instance for this facade.  The attribute name must
be the package (ref($instance)) for the Component.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED) = 0;
# Map of facade classes to instances
my(%_CLASS_MAP);
# Map of facade URIs to instances.
my(%_URI_MAP);
# List of components which have registered.
my(@_COMPONENTS);
my($_DEFAULT) = 'Prod';
Bivio::IO::Config->register({
    default =>  $_DEFAULT,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref config) : Bivio::UI::Facade

Create a new Facade.  I<config> is a list of components
and attributes (see above).  Each component's class is configured
with one value, e.g.:

    __PACKAGE__->new({
        clone => 'Prod',
        'Bivio::UI::Color' => {
            clone => 'AlternateProdLook',
            initialize => sub {
                my($comp) = @_;
                $comp->create_group(
                    0x006666,
                    qw(
			page_vlink
			page_alink
			page_link
			form_field_label_in_text
			task_list_heading
			task_list_label
			footer_menu
                    ),
                );
                $comp->create_group(
	             0x66CC66,
                     'summary_line'
                );
                return;
            }
        },
    });

=cut

sub new {
    my($proto, $config) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto);
    my($class) = ref($self);
    Bivio::IO::Alert->die($class, ': duplicate initialization')
		if $_CLASS_MAP{$class};
    # Not yet initialized, but avoid infinite recursion in the
    # event of self-referential configuration.
    $_CLASS_MAP{$class} = 1;

    # Only load production configuration.
    if (Bivio::Agent::Request->is_production && !$config->{is_production}) {
	# Anybody referencing this facade will get an error; see _load().
	_trace($class, ': non-production Facade, not initializing');
	return undef;
    }

    my($uri) = lc($class);
    $uri =~ s/.*:://;

    # Make sure clone is specified and loaded
    Bivio::IO::Alert->die($class, ': missing clone attribute')
		unless exists($config->{clone});
    my($clone) = $config->{clone} ? _load($config->{clone}) : undef;
    delete($config->{clone});

    # Initialize this instance's attributes
    $self->internal_put({
	uri => $uri,
	is_production => $config->{is_production} ? 1 : 0,
    });
    delete($config->{is_production});

    # Load all relevant components first.  This modifies @_COMPONENTS.
    Bivio::Util::my_require(keys(%$config));

    # Initialize all components
    foreach my $c (@_COMPONENTS) {
	# Get the config for this component (or force to exist)
	my($cfg) = $config->{$c} || {};

	# Get the clone, if any
	my($cc) = $cfg && exists($cfg->{clone})
		? $cfg->{clone} ? _load($cfg->{clone}) : undef : $clone;
	$cc = $cc->get($c) if $cc;

	# Must have a clone or initialize (all components MUST be exist)
	Bivio::IO::Alert->die($class, ': ', $c,
		': missing component clone or initialize attributes')
		    unless $cc || $cfg->{initialize};

	# Create the instance, initialize, seal, and store.
	my($ci) = $c->new($self, $cc);
	&{$cfg->{initialize}}($ci) if $cfg->{initialize};
	$ci->initialization_complete;
	$self->put($c => $ci);
	delete($config->{$c});
    }

    # Make sure everything in $config is valid.
    Bivio::IO::Alert->die(ref($self), ': unknown config (modules not ',
	    ' FacadeComponents(?): ', $config) if %$config;

    # Finish initialization
    $_CLASS_MAP{$class} = $_URI_MAP{$uri} = $self;
    $self->set_read_only();
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_uri_list"></a>

=head2 static get_uri_list() : array_ref

Returns a list of URIs which identify the configured facades.

=cut

sub get_uri_list {
    return [keys(%_URI_MAP)];
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item default : string [Prod]

The default facade class to use, if no facade is specified or
not found.  C<Bivio::UI::Facade::> will be inserted if not
a fully qualified class name.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DEFAULT = $cfg->{default};
    # Insert
    $_DEFAULT = __PACKAGE__.'::'.$_DEFAULT unless $_DEFAULT =~ /::/;
    return;
}

=for html <a name="initialize"></a>

=head2 static initialize()

Initializes this module.  Must be called before use.
Loads all Facades found in subdir of where this package was loaded.

=cut

sub initialize {
    return if $_INITIALIZED;
    # Prevent recursion.  Initialization isn't re-entrant
    $_INITIALIZED = 1;

    # Compute the location where this module was loaded from by
    # turning this module into a perl module path name, looking
    # up in %INC, then turning into a glob pattern
    my($pat) = __PACKAGE__;
    $pat =~ s,::,/,g;
    $pat .= '.pm';
    $pat = $INC{$pat};
    $pat =~ s/(\.pm)$/\/*$1/;

    # Find all Facades
    my(@classes);
    foreach my $file (glob($pat)) {
	my($m) = $file;
	$m =~ s,.*/,,;
	$m =~ s/\.pm//;
	push(@classes, __PACKAGE__.'::'.$m);
    }

    # Load 'em up
    Bivio::Util::my_require(@classes);

    # Make sure the default facade is there and was properly initialized
    Bivio::IO::Alert->die($_DEFAULT,
	    ': unable to find or load default Facade')
		unless ref($_CLASS_MAP{$_DEFAULT});

    # Make sure we loaded all components for all Facades
    foreach my $f (values(%_CLASS_MAP)) {
	foreach my $c (@_COMPONENTS) {
	    Bivio::IO::Alert->die($f, ': ', $c, ': failed to load component')
			unless $f->get($c);
	}
    }
    return;
}

=for html <a name="register"></a>

=head2 static register(array_ref required_components)

Registers new calling package.  I<required_components> is the list of
classes which this component uses or C<undef>.   I<required_components>
will be loaded dynamically.

=cut

sub register {
    my(undef, $required_components) = @_;
    my($component_class) = caller;

    # Load prerequisites first, so they register.  This forces the
    # toposort.
    Bivio::Util::my_require(@$required_components)
		if $required_components;

    # Assert that this component is kosher.
    Bivio::IO::Alert->die($component_class, ': is not a FacadeComponent')
		unless $component_class->isa('Bivio::UI::FacadeComponent');
    Bivio::IO::Alert->die($component_class, ': already registered')
		if grep($_ eq $component_class, @_COMPONENTS);

    # Register this component
    push(@_COMPONENTS, $component_class);
    return;
}

=for html <a name="setup_request"></a>

=head2 static setup_request(string uri, Bivio::Collection::Attributes req)

Sets up the request with the appropriate Facade.  Sets the attribute
I<facade> as well as all the components.  If I<uri> is not a valid
Facade, writes a warning (only once) and uses the default Facade.

Only outputs the warning once.

=cut

sub setup_request {
    my($proto, $uri, $req) = @_;
    my($self);
    if (defined($uri)) {
	$uri = lc($uri);
	$self = $_URI_MAP{$uri};
	unless ($self) {
	    Bivio::IO::Alert->warn($uri, ': unknown facade uri');
	    # Avoid repeated errors
	    $self = $_URI_MAP{$uri} = $_CLASS_MAP{$_DEFAULT};
	}
	elsif ($_TRACE) {
	    _trace($uri);
	}
    }
    else {
	_trace('using default') if $_TRACE;
	$self = $_CLASS_MAP{$_DEFAULT};
    }

    # Put facade and component map on request
    my($attrs) = $self->internal_get;
    $req->put(facade => $self, map {($_, $attrs->{$_})} @_COMPONENTS);
    return;
}

#=PRIVATE METHODS

# _load(string class) : Bivio::UI::Facade
#
# Loads a facade if not already loaded.
#
sub _load {
    my($clone) = @_;
    $clone = __PACKAGE__.'::'.$clone unless $clone =~ /::/;
    Bivio::Util::my_require($clone);
    Bivio::IO::Alert->die($clone, ': not a Bivio::UI::Facade')
		unless UNIVERSAL::isa($clone, 'Bivio::UI::Facade');
    Bivio::IO::Alert->die($clone, ": did not call this module's new "
	    ." (non-production Facade?") unless ref($_CLASS_MAP{$clone});
    return $_CLASS_MAP{$clone};
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
