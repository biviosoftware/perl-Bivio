# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade;
use strict;
$Bivio::UI::Facade::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Facade::VERSION;

=head1 NAME

Bivio::UI::Facade - determines the outward representation of a set of components

=head1 RELEASE SCOPE

bOP

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

=item components : array_ref (facade,computed)

List of component instances for this facade.

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

=item local_file_prefix : string (facade) [Facade.uri]

Used by L<get_local_file_name|"get_local_file_name"> to create
the absolute file name to return.  Always ends in a '/'.  Defaults
to I<Facade.uri>.

=item parent : Bivio::UI::Facade (children)

Parent facade.

=item uri : string (facade) [simple_package_name]

Name of the facade as it appears in domain names and URIs.
Defaults to the lower case version of Facade's simple package name.

=item want_local_file_cache : boolean (facade) [Bivio::UI::Facade.want_local_file_cache]

Should local files be cached?  Typically, this is not set on the
facade, but in the configuration.  See L<handle_config|"handle_config">.

=item E<lt>SimpleClassE<gt> : Bivio::UI::FacadeComponent (facade)

Component instance for this facade.  The attribute name must
be the simple package name for the Component.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::UI::FacadeChildType;
use Bivio::UI::LocalFileType;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_INITIALIZED) = 0;
# Map of facade classes to instances
my(%_CLASS_MAP);
# Map of facade URIs to instances.
my(%_URI_MAP);
# Simple class name -> full class name for components
my(%_COMPONENTS);
# Simple class names sorted topologically (prereqs first)
my(@_COMPONENTS);
my($_DEFAULT) = 'Prod';
# Always ends in a trailing slash
my($_LOCAL_FILE_ROOT);
my($_WANT_LOCAL_FILE_CACHE) = 1;
Bivio::IO::Config->register({
    default =>  $_DEFAULT,
    local_file_root => Bivio::IO::Config->REQUIRED,
    want_local_file_cache => $_WANT_LOCAL_FILE_CACHE,
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
    my($simple_class) = $self->simple_package_name;
    Bivio::Die->die($class, ': duplicate initialization')
		if $_CLASS_MAP{$simple_class};
    # Not yet initialized, but avoid infinite recursion in the
    # event of self-referential configuration.
    $_CLASS_MAP{$simple_class} = 1;

    # Only load production configuration.
    if (Bivio::Agent::Request->is_production && !$config->{is_production}) {
	# Anybody referencing this facade will get an error; see _load().
	_trace($class, ': non-production Facade, not initializing');
	delete($_CLASS_MAP{$simple_class});
	return undef;
    }

    # Make sure clone is specified and loaded
    Bivio::Die->die($class, ': missing clone attribute')
		unless exists($config->{clone});
    my($clone) = $config->{clone} ? _load($config->{clone}) : undef;
    delete($config->{clone});

    # Check the uri after the clone is loaded.
    my($uri) = lc($config->{uri} || $simple_class);
    my($lfp) = $config->{local_file_prefix};
    $lfp = $uri unless defined($lfp);
    my($wlfc) = $config->{want_local_file_cache};
    $wlfc = $_WANT_LOCAL_FILE_CACHE unless defined($wlfc);

    # Not in use
    delete($config->{uri});
    delete($config->{local_file_prefix});
    delete($config->{want_local_file_cache});

    Bivio::Die->die($uri, ': duplicate uri for ', $class, ' and ',
	    ref($_URI_MAP{$uri}))
		if $_URI_MAP{$uri};
    _trace($class, ': uri=', $uri) if $_TRACE;

    # Initialize this instance's attributes
    $self->internal_put({
	uri => $uri,
	local_file_prefix => Bivio::Type::FileName->add_trailing_slash($lfp),
	want_local_file_cache => $wlfc,
	is_production => $config->{is_production} ? 1 : 0,
	is_default => $_DEFAULT eq $self->simple_package_name ? 1 : 0,
	children => {},
    });
    delete($config->{is_production});

    # Load all components before initializing.  This modifies @ & %_COMPONENTS.
    foreach my $comp (keys(%$config)) {
	my($c) = Bivio::IO::ClassLoader->map_require('FacadeComponent', $comp);
	$c->handle_register;
    }
    _initialize($self, $config, $clone);

    # Store globally
    $_CLASS_MAP{$simple_class} = $_URI_MAP{$uri} = $self;
    return $self;
}

=for html <a name="new_child"></a>

=head2 new_child(hash_ref config) : Bivio::UI::Facade

Creates a child of I<self> (parent).  The I<child_type> attribute
must be set, but no other attributes except components should
be set.  The clone is always the parent.  Components without
a child initialize are shared fully, i.e. the parent's values
and groups are copied verbatim to the child's.

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
	(map {
	    ($_, $parent->get($_));
	} qw(uri local_file_prefix want_local_file_cache is_production)),
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
    return 'Facade['.$self->simple_package_name.'.'.lc($type->get_name).']';
}

=for html <a name="get_default"></a>

=head2 get_default() : Bivio::UI::Facade

Get the default facade.

=cut

sub get_default {
    return $_CLASS_MAP{$_DEFAULT};
}

=for html <a name="get_from_request_or_self"></a>

=head2 static get_from_request_or_self(Bivio::Collection::Attributes req_or_facade) : self

Returns facade from the I<req_or_facade> or just I<req_or_facade> if
it isa Facade.

If I<req_or_facade> is C<undef>, uses
L<Bivio::Agent::Request::get_current|Bivio::Agent::Request/"get_current">.

=cut

sub get_from_request_or_self {
    my($proto, $req_or_facade) = @_;
    if (ref($req_or_facade)) {
	return $req_or_facade if UNIVERSAL::isa($req_or_facade, __PACKAGE__);
    }
    else {
	# Not defined, just get current
	$req_or_facade = Bivio::Agent::Request->get_current;
    }
    return $req_or_facade->get(__PACKAGE__);
}

=for html <a name="get_local_file_name"></a>

=head2 get_local_file_name(Bivio::UI::LocalFileType type, string name) : string

=head2 static get_local_file_name(Bivio::UI::LocalFileType type, string name, Bivio::Collection::Attributes req_or_facade) : string

Returns the absolute path for the file I<name> (usually a URI) with file
I<type> which can be opened locally using perl's open.  The structure of
the resultant file should not be assumed except that I<name> is the last
component.

There is no guarantee the file identified by the returned path exists.

For informational purposes, here's how the absolute path is
currently constructed:

    local_file_root/local_file_prefix/type->get_path/name

I<Bivio::UI::Facade.local_file_root> is part of this class's configuration.
I<Facade.local_file_prefix> is an attribute of the facade.

May not be called statically if I<req> is C<undef>.

=cut

sub get_local_file_name {
    my($self, $type, $name, $req) = @_;
    $self = $self->get_from_request_or_self($req)
	    if defined($req) || !ref($self);
    return $_LOCAL_FILE_ROOT.$self->get('local_file_prefix')
	    .$type->get_path.$name;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item default : string [Prod]

The default facade class to use, if no facade is specified or
not found.  C<Bivio::UI::Facade::> will be inserted if not
a fully qualified class name.

=item local_file_root : string (required)

The root of all files (icons, documents, views) read from this hosts disks
for all facades.

=item want_local_file_cache : boolean [true]

The default value for I<Facade.want_local_file_cache>.  If true, local file
information will be cached by users.  This can be a performance benefit at the
expense of memory consumption.  L<Bivio::UI::View|Bivio::UI::View> will
pre-compile all views.  L<Bivio::UI::Icon|Bivio::UI::Icon> will
cache all icon sizes.

For development, you probably want to set I<want_local_file_cache> to false.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DEFAULT = $cfg->{default};
    Bivio::Die->die($cfg->{local_file_root},
	    ": local_file_root is not a directory")
		unless $cfg->{local_file_root} && -d $cfg->{local_file_root};
    $_LOCAL_FILE_ROOT = Bivio::Type::FileName->add_trailing_slash(
	    $cfg->{local_file_root});
    $_WANT_LOCAL_FILE_CACHE = $cfg->{want_local_file_cache};
    return;
}

=for html <a name="initialize"></a>

=head2 static initialize(boolean partially)

Initializes this module.  Must be called before use.
Loads all Facades found in subdir of where this package was loaded.

If I<partially>, only initializes the default facade.  B<Do not use
in a server environment.>

=cut

sub initialize {
    my($proto, $partially) = @_;
    return if $_INITIALIZED;
    # Prevent recursion.  Initialization isn't re-entrant
    $_INITIALIZED = 1;

    if ($partially) {
	Bivio::IO::ClassLoader->map_require('Facade', $_DEFAULT);
    }
    else {
	Bivio::IO::ClassLoader->map_require_all('Facade');
    }

    # Make sure the default facade is there and was properly initialized
    Bivio::Die->die($_DEFAULT,
	    ': unable to find or load default Facade')
		unless ref($_CLASS_MAP{$_DEFAULT});

    Bivio::IO::ClassLoader->simple_require('Bivio::UI::Icon');
    Bivio::IO::ClassLoader->simple_require('Bivio::UI::View');

    # Make sure we loaded all components for all Facades and
    # initialize Icons and Views.
    foreach my $f (values(%_CLASS_MAP)) {
	foreach my $c (@_COMPONENTS) {
	    Bivio::Die->die($f, ': ', $c, ': failed to load component')
			unless $f->get($c);
	}
	# Icons used before views
	Bivio::UI::Icon->initialize_by_facade($f);
	Bivio::UI::View->initialize_by_facade($f);
    }
    return;
}

=for html <a name="prepare_to_render"></a>

=head2 static prepare_to_render(Bivio::Agent::Request req) : self

=head2 static prepare_to_render(Bivio::Agent::Request req, Bivio::UI::FacadeChildType child_type) : self

Called before rendering to lookup the user preference
I<facade_child_type> if not passed and set on the request.

=cut

sub prepare_to_render {
    my(undef, $req, $type) = @_;
    my($self) = $req->get(__PACKAGE__);
    my($children) = $self->unsafe_get('children');

    # No children?  If already a child, then got an error during
    # rendering or server_redirect(?) and we should just stay in the
    # same facade.
    unless ($children && %$children) {
	_trace($self, ': no children') if $_TRACE;
	return;
    }

    # If there is no child of this type, default case
    $type = Bivio::Societas::Biz::Model::Preferences->get_user_pref($req,
	    'facade_child_type');
    Bivio::Auth::Support->unsafe_get_user_pref(
	    'FACADE_CHILD_TYPE', $req, \$type)
	    unless $type;
    unless ($children->{$type}) {
	_trace($self, ': ', $type, ': no such child') if $_TRACE;
	return;
    }

    return _setup_request($children->{$type}, $req);
}

=for html <a name="register"></a>

=head2 static register(string class, array_ref required_components)

Registers new calling package.  I<required_components> is the list of
classes which this component uses or C<undef>.   I<required_components>
will be loaded dynamically.

=cut

sub register {
    my(undef, $class, $required_components) = @_;
    my($simple_class) = $class->simple_package_name;

    # Avoid recursion
    return if exists($_COMPONENTS{$simple_class});
    $_COMPONENTS{$simple_class} = undef;

    # Load prerequisites first, so they register.  This forces the
    # toposort.
    foreach my $c (@$required_components) {
	Bivio::IO::ClassLoader->map_require('FacadeComponent', $c)
		    ->handle_register;
    }

    # Assert that this component is kosher.
    Bivio::Die->die($class, ': is not a FacadeComponent')
		unless $class->isa('Bivio::UI::FacadeComponent');
    Bivio::Die->die($class, ': already registered')
		if $_COMPONENTS{$simple_class};

    # Register this component
    push(@_COMPONENTS, $simple_class);
    $_COMPONENTS{$simple_class} = $class;
    return;
}

=for html <a name="setup_request"></a>

=head2 static setup_request(string uri, Bivio::Collection::Attributes req) : sel

Sets up the request with the appropriate Facade.  Sets the attribute
I<Bivio::UI::Facade>.  If I<uri> is not a valid Facade, writes a warning (only
once) and uses the default Facade.

Only outputs the warning once.

Returns the facade.

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
    return _setup_request($self, $req);
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
	$self->put($c => $_COMPONENTS{$c}->new(
		$self, $cc, $cfg->{initialize}));
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
    my($c) = Bivio::IO::ClassLoader->map_require('Facade', $clone);
    Bivio::Die->die($c, ': not a Bivio::UI::Facade')
		unless UNIVERSAL::isa($c, 'Bivio::UI::Facade');
    Bivio::Die->die($c, ": did not call this module's new "
	    ." (non-production Facade?") unless ref($_CLASS_MAP{$clone});
    return $_CLASS_MAP{$clone};
}

# _setup_request(Bivio::UI::Facade self, Bivio::Agent::Request req) : self
#
# Puts Bivio::UI::Facade on request with $self
#
sub _setup_request {
    my($self, $req) = @_;
    $req->put_durable($_PACKAGE => $self);
    _trace($self) if $_TRACE;
    return $self;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
