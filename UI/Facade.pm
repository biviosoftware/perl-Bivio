# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade;
use strict;
$Bivio::UI::Facade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::VERSION;

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

=item children : hash_ref (facade)

The children of this Facade.  The keys are
L<Bivio::UI::FacadeChildType|Bivio::UI::FacadeChildType>
and values are facades.  A child may be undef or
there may be no children at all.

Children do not have children, i.e. the tree is only two levels deep.

=item child_type : Bivio::UI::FacadeChildType (children)

The type of this child.  Must be unique to all children of
this Facade.

=item initialize : sub (component)

The initialization attribute is a C<sub> to initialize a Component.
I<initialize> takes one argument: the Component being initialized.
The component will already have the I<facade> to which it belongs
as an attribute when I<initialize> is called.

=item is_default : boolean (facade)

Returns true if this is the default facade.

=item is_production : boolean (facade)

If set to true, the Facade will be found in a production environment.
Otherwise, won't be initialized if not running in the
production environment.

=item parent : Bivio::UI::Facade (children)

Parent facade.

=item uri : string (facade)

Name of the facade as it appears in domain names and URIs.
The base name of the Facade's package.

=item E<lt>ModuleE<gt> : Bivio::UI::FacadeComponent (facade)

Component instance for this facade.  The attribute name must
be the package (ref($instance)) for the Component.

=back

=head2 URI TO CLASS LIST

Each Facade class can assign its own uri, but they must all be
unique.  The code words should be used only once.  Once a facade
is in production or in test for production, its real URI should be
used.

=over 4

=item ic : BUYandHOLD (production)

=item investmentexpo : InvestmentExpo (production)

=item aristau : WFN

=item muri :

=item cimo : eklubs

=item dubeli : fool

=item bumpliz : AllWomenInvest

=item ollon :

=item stange :

=item schnipo :

=item boelle :

=item laedli :

=item uetli :

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::UI::FacadeChildType;

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
    Bivio::Die->die($class, ': duplicate initialization')
		if $_CLASS_MAP{$class};
    # Not yet initialized, but avoid infinite recursion in the
    # event of self-referential configuration.
    $_CLASS_MAP{$class} = 1;

    # Only load production configuration.
    if (Bivio::Agent::Request->is_production && !$config->{is_production}) {
	# Anybody referencing this facade will get an error; see _load().
	_trace($class, ': non-production Facade, not initializing');
	delete($_CLASS_MAP{$class});
	return undef;
    }

    # Make sure clone is specified and loaded
    Bivio::Die->die($class, ': missing clone attribute')
		unless exists($config->{clone});
    my($clone) = $config->{clone} ? _load($config->{clone}) : undef;
    delete($config->{clone});

    # Check the uri after the clone is loaded.
    my($uri) = lc($config->{uri});
    unless ($uri) {
	$uri = lc($class);
	$uri =~ s/.*:://;
    }
    delete($config->{uri});
    Bivio::Die->die($uri, ': duplicate uri for ', $class, ' and ',
	    ref($_URI_MAP{$uri}))
		if $_URI_MAP{$uri};
    _trace($class, ': uri=', $uri) if $_TRACE;

    # Initialize this instance's attributes
    $self->internal_put({
	uri => $uri,
	is_production => $config->{is_production} ? 1 : 0,
	is_default => $_DEFAULT eq $class ? 1 : 0,
	children => {},
    });
    delete($config->{is_production});

    # Load all relevant components first.  This modifies @_COMPONENTS.
    Bivio::IO::ClassLoader->simple_require(keys(%$config));

    _initialize($self, $config, $clone);

    # Store globally
    $_CLASS_MAP{$class} = $_URI_MAP{$uri} = $self;
    return $self;
}

=for html <a name="new_child"></a>

=head2 new_child(hash_ref config) : Bivio::UI::Facade

Creates a child of I<self> (parent).  The I<child_type> attribute
must be set, but no other attributes except components should
be set.  The clone is always the parent.

=cut

sub new_child {
    my($parent, $config) = @_;

    # Will blow up if not a parent (main facade).
    my($children) = $parent->get('children');

    my($self) = Bivio::Collection::Attributes::new($parent);

    # Initialize this instance's attributes
    my($type) = Bivio::UI::FacadeChildType->from_any($config->{child_type});
    delete($config->{child_type});
    $self->internal_put({
	uri => $parent->get('uri'),
	is_production => $parent->get('is_production'),
	is_default => 0,
	child_type => $type,
	parent => $parent,
    });

    Bivio::Die->die($self, ': duplicate child type initialization')
		if $children->{$type};

    # This is actually very inefficient, because we copy the entire
    # parent facade to the child.  Most of it can probably be shared.
    _initialize($self, $config, $parent);

    # This is allowed even though the parent is already read-only
    $children->{$type} = $self;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns string representation of the Facade.

=cut

sub as_string {
    my($self) = @_;
    my($type) = $self->unsafe_get('type')
	    || Bivio::UI::FacadeChildType->DEFAULT;
    return $self->simple_package_name.'.'.lc($type->get_name);
}

=for html <a name="get_default"></a>

=head2 get_default() : Bivio::UI::Facade

Get the default facade.

=cut

sub get_default {
    return $_CLASS_MAP{$_DEFAULT};
}

=for html <a name="get_uri_list"></a>

=head2 static get_uri_list() : array_ref

B<Only to be used by b-http-dispatcher.>

Returns a list of URIs which identify the configured facades.

=cut

sub get_uri_list {
    return [keys(%_URI_MAP)] if $_INITIALIZED;

    # HACK: We aren't initialized, but b-http-dispatcher would like
    # the list, so we'll just take a quick guess.
    die("caller isn't b-http-dispatcher")
	    if (caller(0))[3] =~ /::main$/;

    my($pat) = _get_class_pattern();
    my(@uri);
    foreach my $file (glob($pat)) {
	open(IN, $file) || next;
	# Find the uri if set, otherwise the package base name in lc.
	my($uri) = $file;
	$uri =~ s/.*\/(\w+)\.pm$/\L$1/;
	my($uri2) = grep(s/^\s*uri\s*=>\s*['"](\w+).*\n/\L$1/, <IN>);  	 #emacs
	push(@uri, $uri2 || $uri);
    }
    close(IN);
    _trace(\@uri) if $_TRACE;
    return \@uri;
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

    my($pat) = _get_class_pattern();

    # Find all Facades
    my(@classes);
    foreach my $file (glob($pat)) {
	my($m) = $file;
	$m =~ s,.*/,,;
	$m =~ s/\.pm//;
	push(@classes, __PACKAGE__.'::'.$m);
    }


    # Load 'em up
    Bivio::IO::ClassLoader->simple_require(@classes);

    # Make sure the default facade is there and was properly initialized
    Bivio::Die->die($_DEFAULT,
	    ': unable to find or load default Facade')
		unless ref($_CLASS_MAP{$_DEFAULT});

    # Make sure we loaded all components for all Facades
    foreach my $f (values(%_CLASS_MAP)) {
	foreach my $c (@_COMPONENTS) {
	    Bivio::Die->die($f, ': ', $c, ': failed to load component')
			unless $f->get($c);
	}
    }
    return;
}

=for html <a name="prepare_to_render"></a>

=head2 static prepare_to_render(Bivio::Agent::Request req)

Called before rendering to lookup the user preference
I<facade_child_type> and set on the request.

=cut

sub prepare_to_render {
    my(undef, $req) = @_;
    my($self) = $req->get('facade');
    my($children) = $self->unsafe_get('children');

    # No children?  If already a child, then got an error during
    # rendering or server_redirect(?) and we should just stay in the
    # same facade.
    return unless $children && %$children;

    # No child of this type (could be default case)?
    my($type) = $req->get_user_pref('facade_child_type');
    return unless $children->{$type};

    _setup_request($children->{$type}, $req);
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
    Bivio::IO::ClassLoader->simple_require(@$required_components)
		if $required_components;

    # Assert that this component is kosher.
    Bivio::Die->die($component_class, ': is not a FacadeComponent')
		unless $component_class->isa('Bivio::UI::FacadeComponent');
    Bivio::Die->die($component_class, ': already registered')
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
    }
    else {
	$self = $_CLASS_MAP{$_DEFAULT};
    }

    _setup_request($self, $req);
    return;
}

#=PRIVATE METHODS

# _get_class_pattern() : string
#
# Returns a pattern to find the classes to be loaded.
#
sub _get_class_pattern {
    # Compute the location where this module was loaded from by
    # turning this module into a perl module path name, looking
    # up in %INC, then turning into a glob pattern
    my($pat) = __PACKAGE__;
    $pat =~ s,::,/,g;
    $pat .= '.pm';
    $pat = $INC{$pat};
    $pat =~ s/(\.pm)$/\/*$1/;
    return $pat;
}

# _initialize(Bivio::UI::Facade self, hash_ref config, Bivio::UI::Facade clone)
#
# Initializes the facade from config and clone.
#
sub _initialize {
    my($self, $config, $clone) = @_;
    # Initialize all components
    foreach my $c (@_COMPONENTS) {
	# Get the config for this component (or force to exist)
	my($cfg) = $config->{$c} || {};

	# Get the clone, if any
	my($cc) = $cfg && exists($cfg->{clone})
		? $cfg->{clone} ? _load($cfg->{clone}) : undef : $clone;
	$cc = $cc->get($c) if $cc;

	# Must have a clone or initialize (all components MUST be exist)
	Bivio::Die->die($self, ': ', $c,
		': missing component clone or initialize attributes')
		    unless $cc || $cfg->{initialize};

	# Create the instance, initialize, seal, and store.
	$self->put($c => $c->new($self, $cc, $cfg->{initialize}));
	delete($config->{$c});
    }

    # Make sure everything in $config is valid.
    Bivio::Die->die($self, ': unknown config (modules not ',
	    ' FacadeComponents(?): ', $config) if %$config;

    # No more modifications allowed
    $self->set_read_only();
    return;
}

# _load(string class) : Bivio::UI::Facade
#
# Loads a facade if not already loaded.
#
sub _load {
    my($clone) = @_;
    $clone = __PACKAGE__.'::'.$clone unless $clone =~ /::/;
    Bivio::IO::ClassLoader->simple_require($clone);
    Bivio::Die->die($clone, ': not a Bivio::UI::Facade')
		unless UNIVERSAL::isa($clone, 'Bivio::UI::Facade');
    Bivio::Die->die($clone, ": did not call this module's new "
	    ." (non-production Facade?") unless ref($_CLASS_MAP{$clone});
    return $_CLASS_MAP{$clone};
}

# _setup_request(Bivio::UI::Facade self, Bivio::Agent::Request req)
#
# Sets facade and components on request.
#
sub _setup_request {
    my($self, $req) = @_;
    # Put facade and component map on request
    my($attrs) = $self->internal_get;
    $req->put(facade => $self, map {($_, $attrs->{$_})} @_COMPONENTS);
    _trace($self) if $_TRACE;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
