# Copyright (c) 2000-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::FileName;
use Bivio::UI::FacadeChildType;
use Bivio::UI::LocalFileType;

# C<Bivio::UI::Facade> is a collection of instances which present a uniform
# view.  Typically, a Facade is used to represent UI components.  An
# Facade instance is a collection of attributes.  Most of the attributes
# are identified by their components' package names.  There are some
# other attributes, e.g. I<clone>, which are defined below.
#
# A Facade components L<register|"register"> with this module, statically.
#
#
# There are two types of attributes: I<facade> and I<component>.
# A I<facade> attribute is on the whole Facade.  A I<component>
# attribute is configured for the Component.
#
#
# clone : Bivio::UI::Facade (facade,component)
#
# The base map for this Facade.  If C<undef>, there is no base.
# A component is always instantiated from a clone or as a new instance.
# The default I<clone> is on the Facade and must always be specified
# (even if C<undef>).  The I<clone> may be overriden in a particular
# component's configuration.
#
# children : hash_ref (facade)
#
# The children of this Facade.  The keys are
# L<Bivio::UI::FacadeChildType|Bivio::UI::FacadeChildType>
# and values are facades.  A child may be undef or
# there may be no children at all.
#
# Children do not have children, i.e. the tree is only two levels deep.
#
# child_type : Bivio::UI::FacadeChildType (children)
#
# The type of this child.  Must be unique to all children of
# this Facade.
#
# components : array_ref (facade,computed)
#
# List of component instances for this facade.
#
# cookie_domain : string
#
# The domain to use for the cookie.
#
# http_host : string (facade, computed)
#
# Host to create absolute URIs.  May contain a port number.
#
# initialize : sub (component)
#
# The initialization attribute is a C<sub> to initialize a Component.
# I<initialize> takes one argument: the Component being initialized.
# The component will already have the I<facade> to which it belongs
# as an attribute when I<initialize> is called.
#
# is_default : boolean (facade)
#
# Returns true if this is the default facade.
#
# is_production : boolean (facade)
#
# If set to true, the Facade will be found in a production environment.
# Otherwise, won't be initialized if not running in the
# production environment.
#
# local_file_prefix : string (facade) [Facade.uri]
#
# Used by L<get_local_file_name|"get_local_file_name"> to create
# the absolute file name to return.  Always ends in a '/'.  Defaults
# to I<Facade.uri>.
#
# mail_host : string (facade, computed)
#
# Host used to create mail_to URIs.
#
# parent : Bivio::UI::Facade (children)
#
# Parent facade.
#
# uri : string (facade) [simple_package_name]
#
# Name of the facade as it appears in domain names and URIs.
# Defaults to the lower case version of Facade's simple package name.
#
# want_local_file_cache : boolean (facade) [Bivio::UI::Facade.want_local_file_cache]
#
# Should local files be cached?  Typically, this is not set on the
# facade, but in the configuration.  See L<handle_config|"handle_config">.
#
# E<lt>SimpleClassE<gt> : Bivio::UI::FacadeComponent (facade)
#
# Component instance for this facade.  The attribute name must
# be the simple package name for the Component.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_INITIALIZED) = 0;
my(%_CLASS_MAP);
my(%_URI_MAP);
my(%_COMPONENTS);
my(@_COMPONENTS);
my($_STATIC_COMPONENTS) = [qw(Email Icon View)];
Bivio::IO::Config->register(my $_CFG = {
    default => Bivio::IO::Config->REQUIRED,
    # Always ends in a trailing slash
    local_file_root => Bivio::IO::Config->REQUIRED,
    want_local_file_cache => 1,
    mail_host => Bivio::IO::Config->REQUIRED,
    http_suffix => Bivio::IO::Config->REQUIRED,
});
my($_IS_FULLY_INITIALIZED) = 0;

sub as_string {
    my($self) = @_;
    # Returns string representation of the Facade.
    my($type) = $self->unsafe_get('type')
	    || Bivio::UI::FacadeChildType->DEFAULT;
    return 'Facade['.$self->simple_package_name.'.'.lc($type->get_name).']';
}

sub get_all_classes {
    # List of all Facades by simple class name.  Must be fully initialized to call
    # this function.
    die('not all classes available, because not fully initialized')
	unless shift->is_fully_initialized;
    return [sort(keys(%_CLASS_MAP))];
}

sub get_default {
    # Get the default facade.
    return $_CLASS_MAP{$_CFG->{default}};
}

sub get_from_request_or_self {
    my($proto, $req_or_facade) = @_;
    # Returns facade from the I<req_or_facade> or just I<req_or_facade> if
    # it isa Facade.
    #
    # If I<req_or_facade> is C<undef>, uses
    # L<Bivio::Agent::Request::get_current|Bivio::Agent::Request/"get_current">.
    if (ref($req_or_facade)) {
	return $req_or_facade
	    if UNIVERSAL::isa($req_or_facade, __PACKAGE__);
    }
    else {
	$req_or_facade = Bivio::Agent::Request->get_current;
    }
    return $proto->get_from_source($req_or_facade);
}

sub get_from_source {
    my(undef, $source) = @_;
    return $source->req(__PACKAGE__);
}

sub get_instance {
    my($proto, $simple_class) = @_;
    # Returns facade instance for I<simple_class>.  Facade must be initialized.
    # Returns default facade, if I<simple_class> is C<undef> or false.
    return $simple_class
	? $_CLASS_MAP{$simple_class}
	    || Bivio::Die->die($simple_class, ': no such facade')
	: $proto->get_default
}

sub get_local_file_name {
    my($self, $type, $name, $req) = @_;
    # Returns the absolute path for the file I<name> (usually a URI) with file
    # I<type> which can be opened locally using perl's open.  The structure of
    # the resultant file should not be assumed except that I<name> is the last
    # component.
    #
    # There is no guarantee the file identified by the returned path exists.
    #
    # For informational purposes, here's how the absolute path is
    # currently constructed:
    #
    #     local_file_root/local_file_prefix/type->get_path/name
    #
    # I<Bivio::UI::Facade.local_file_root> is part of this class's configuration.
    # I<Facade.local_file_prefix> is an attribute of the facade.
    #
    # May not be called statically if I<req> is C<undef>.
    $self = $self->get_from_request_or_self($req)
	if defined($req) || !ref($self);
    return $self->get_local_file_root . $self->get('local_file_prefix')
	. Bivio::UI::LocalFileType->from_any($type)->get_path
	. $name;
}

sub get_local_file_root {
    # Returns I<local_file_root> configuration.
    return $_CFG->{local_file_root};
}

sub get_value {
    my($proto, $name, $req_or_facade) = @_;
    # Return an attribute of the current facade.
    # Make a copy for safety reasons
    return $proto->get_from_request_or_self($req_or_facade)->get($name);
}

sub handle_config {
    my(undef, $cfg) = @_;
    # default : string (required)
    #
    # The default facade class to use, if no facade is specified or
    # not found.  C<Bivio::UI::Facade::> will be inserted if not
    # a fully qualified class name.
    #
    # http_suffix : string (required)
    #
    # Host to create absolute URIs.  May contain a port number.  Used only in
    # non-production mode.
    #
    # local_file_root : string (required)
    #
    # The root of all files (icons, documents, views) read from this hosts disks
    # for all facades.
    #
    # mail_host : string (required)
    #
    # Host used to create mail_to URIs.
    #
    # want_local_file_cache : boolean [true]
    #
    # The default value for I<Facade.want_local_file_cache>.  If true, local file
    # information will be cached by users.  This can be a performance benefit at the
    # expense of memory consumption.  L<Bivio::UI::View|Bivio::UI::View> will
    # pre-compile all views.  L<Bivio::UI::Icon|Bivio::UI::Icon> will
    # cache all icon sizes.
    #
    # For development, you probably want to set I<want_local_file_cache> to false.
    Bivio::IO::Alert->warn(
	$cfg->{local_file_root}, ': local_file_root is not a directory'
    ) unless $cfg->{local_file_root} && -d $cfg->{local_file_root};
    $cfg->{local_file_root}
	= Bivio::Type::FileName->add_trailing_slash($cfg->{local_file_root});
    $_CFG = {%{$cfg}};
    return;
}

sub handle_unload_package {
    # Delete this class from cache
    return;
}

sub initialize {
    my($proto, $partially) = @_;
    # Initializes this module.  Must be called before use.
    # Loads all Facades found in subdir of where this package was loaded.
    #
    # If I<partially>, only initializes the default facade.  B<Do not use
    # in a server environment.>
    return if $_INITIALIZED;
    $_INITIALIZED = 1;
    # Default must be initialized first
    Bivio::IO::ClassLoader->map_require('Facade', $_CFG->{default});
    Bivio::IO::ClassLoader->map_require_all('Facade')
        unless $partially;
    Bivio::Die->die(
	$_CFG->{default}, ': unable to find or load default Facade',
    ) unless ref($_CLASS_MAP{$_CFG->{default}});
    foreach my $f (values(%_CLASS_MAP)) {
	foreach my $c (@$_STATIC_COMPONENTS) {
	    $f->put($c => Bivio::IO::ClassLoader->map_require(
		'FacadeComponent', $c
	    )->initialize_by_facade($f));
	}
	foreach my $c (@_COMPONENTS) {
	    Bivio::Die->die($f, ': ', $c, ': failed to load component')
	        unless $f->unsafe_get($c);
	}
	$f->set_read_only;
    }
    $_IS_FULLY_INITIALIZED = $partially ? 0 : 1;
    return;
}

sub is_fully_initialized {
    # Returns true if the Facade was has been completely initialized.
    return $_IS_FULLY_INITIALIZED;
}

sub make_groups {
    my($proto, $items) = @_;
    # Converts a series of [(key, value), ...] pairs into [[key, value], ...].
    Bivio::Die->die('uneven number of items in array: ', $items)
        unless @$items % 2 == 0;
    my($result) = [];
    while (@$items) {
        push(@$result, [splice(@$items, 0, 2)]);
    }
    return $result
}

sub new {
    my($proto, $config) = @_;
    # Create a new Facade.  I<config> is a list of components
    # and attributes (see above).  Each component's class is configured
    # with one value, e.g.:
    #
    #     __PACKAGE__->new({
    #         clone => 'Prod',
    #         'Color' => {
    #             clone => 'AlternateProdLook',
    #             initialize => sub {
    #                 my($fc) = @_;
    #                 $fc->group(page_link => 0x330099),
    # 	        $fc->group(['page_vlink', 'page_alink'] => 0x330099),
    #                 return;
    #             }
    #         },
    #     });
    #
    # There are some shortcuts, e.g.
    #
    #     'Color' => sub {
    # 	 shift->map_invoke(group => [
    # 	    [page_link => 0x330099],
    # 	    [['page_vlink', 'page_alink'] => 0x330099],
    # 	 ]);
    # 	 return;
    #      },
    #
    # Or even shorter:
    #
    #     'Color' => [
    # 	 [page_link => 0x330099],
    # 	 [['page_vlink', 'page_alink'] => 0x330099],
    #      ],
    my($self) = $proto->SUPER::new();
    my($class) = ref($self);
    my($simple_class) = $self->simple_package_name;
    Bivio::Die->die($class, ': duplicate initialization')
        if $_CLASS_MAP{$simple_class};
    # Not yet initialized, but avoid infinite recursion in the
    # event of self-referential configuration.
    $_CLASS_MAP{$simple_class} = 1;

    $self->use('Agent.Request');
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
    $wlfc = $_CFG->{want_local_file_cache}
	unless defined($wlfc);

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
	is_default => $_CFG->{default} eq $self->simple_package_name ? 1 : 0,
	children => {},
        cookie_domain => delete($config->{cookie_domain}),
    });
    _init_hosts($self, $config);
    foreach my $x (qw(
        uri local_file_prefix want_local_file_cache is_production
        mail_host http_host)) {
	delete($config->{$x});
    }

    # Load all components before initializing.  Modifies @ & %_COMPONENTS.
    foreach my $c (keys(%$config)) {
	Bivio::IO::ClassLoader->map_require('FacadeComponent', $c)
	    ->handle_register;
    }
    _initialize($self, $config, $clone);

    # Store globally
    $_CLASS_MAP{$simple_class} = $_URI_MAP{$uri} = $self;
    return $self;
}

sub new_child {
    my($parent, $config) = @_;
    my($self) = $parent->SUPER::new;
    my($children) = $parent->get('children');
    my($type) = Bivio::UI::FacadeChildType->from_any($config->{child_type});
    delete($config->{child_type});
    $self->internal_put({
	(map {
	    ($_, $parent->get($_));
	} qw(uri local_file_prefix want_local_file_cache is_production http_host mail_host cookie_domain)),
	is_default => 0,
	child_type => $type,
	parent => $parent,
    });
    b_die($self, ': duplicate child type initialization')
        if $children->{$type};
    _initialize($self, $config, $parent);
    $children->{$type} = $self;
    return $self;
}

sub prepare_to_render {
    my(undef, $req, $type) = @_;
    my($self) = $req->get(__PACKAGE__);
    my($children) = $self->unsafe_get('children');
    unless ($children && %$children) {
	_trace($self, ': no children') if $_TRACE;
	return;
    }
    Bivio::Auth::Support->unsafe_get_user_pref(
	'FACADE_CHILD_TYPE', $req, \$type,
    ) unless $type;
    $type ||= Bivio::UI::FacadeChildType->get_default;
    unless ($children->{$type}) {
	_trace($self, ': ', $type, ': no such child')
	    if $_TRACE;
	return;
    }
    return _setup_request($children->{$type}, $req);
}

sub register {
    my(undef, $class, $required_components) = @_;
    # Registers new calling package.  I<required_components> is the list of
    # classes which this component uses or C<undef>.   I<required_components>
    # will be loaded dynamically.
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

sub setup_request {
    my($proto, $uri_or_domain, $req) = @_;
    # Sets up the request with the appropriate Facade.  Sets the attribute
    # I<Bivio::UI::Facade>.  If I<uri_or_domain> is not a valid Facade, writes a
    # warning (only once) and uses the default Facade.
    #
    # Only outputs the warning once.
    #
    # Returns the facade.
    if (ref($uri_or_domain)) {
	Bivio::Die->die($uri_or_domain, ': is not a Request')
	    unless UNIVERSAL::isa($uri_or_domain, 'Bivio::Agent::Request');
	Bivio::Die->die('must not be called statically')
	    unless ref($proto);
	return _setup_request($proto, $uri_or_domain);
    }
    my($self);
    _trace('uri: ', $uri_or_domain) if $_TRACE;
    if (defined($uri_or_domain)) {
	$uri_or_domain = lc($uri_or_domain);
	foreach my $uri ($uri_or_domain, split(/\./, $uri_or_domain)) {
	    last if $self = $_URI_MAP{$uri};
	}
	unless ($self) {
	    Bivio::IO::Alert->warn($uri_or_domain, ': unknown facade uri');
	    # Avoid repeated errors
	    $self = $_URI_MAP{$uri_or_domain} = $_CLASS_MAP{$_CFG->{default}};
	}
    }
    else {
	$self = $_CLASS_MAP{$_CFG->{default}};
    }
    return _setup_request($self, $req);
}

sub _fixup_test_uri {
    my($self, $uri) = @_;
    return $uri
	if $self->get('is_default');
    my($d) = $self->get_default->get('uri');
    my($f) = $self->get('uri');
    $uri = "$f.$uri"
	unless $uri =~ s{^(.*?)\b\Q$d\E\b}{$1$f}i;
   return $uri;
}

sub _get_class_pattern {
    # Returns a pattern to find the classes to be loaded.
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

sub _init_hosts {
    my($self, $config) = @_;
    $self->put(
	map(($_ => (
	    Bivio::Agent::Request->is_production
	        ? $config->{$_} || Bivio::Die->die(
		    $_, ': facade parameter missing in production')
		: _fixup_test_uri($self, $_CFG->{$_} || $_CFG->{http_suffix}),
	)), qw(http_host mail_host)),
    );
    return;
}

sub _initialize {
    my($self, $config, $clone) = @_;
    foreach my $c (@$_STATIC_COMPONENTS) {
	$self->put($c => Bivio::IO::ClassLoader->map_require(
	    'FacadeComponent', $c
	)->initialize_by_facade($self));
    }
    foreach my $c (@_COMPONENTS) {
	# Get the config for this component (or force to exist)
	my($cfg) = $config->{$c} || {};
	if (ref($cfg) eq 'ARRAY') {
	    # closure must be bound to new a variable
	    my($groups) = $cfg;
	    $cfg = sub {
		shift->map_invoke(group => $groups);
		return;
	    };
	}
	$cfg = {initialize => $cfg}
	    if ref($cfg) eq 'CODE';

	# Get the clone, if any
	my($cc) = $cfg && exists($cfg->{clone})
	    ? $cfg->{clone} ? _load($cfg->{clone}) : undef : $clone;
	$cc = $cc->get($c) if $cc;

	# Must have a clone or initialize (all components MUST be exist)
	Bivio::Die->die(
	    $self, ': ', $c,
	    ': missing component clone or initialize attributes',
	) unless $cc || $cfg->{initialize};

	# Create the instance, initialize, seal, and store.
	$self->put($c => $_COMPONENTS{$c}->new(
	    $self, $cc, $cfg->{initialize}));
	delete($config->{$c});
    }

    # Make sure everything in $config is valid.
    Bivio::Die->die($self, ': unknown config (modules not ',
	    ' FacadeComponents(?): ', $config) if %$config;

    return;
}

sub _load {
    my($clone) = @_;
    # Loads a facade if not already loaded.
    my($c) = Bivio::IO::ClassLoader->map_require('Facade', $clone);
    Bivio::Die->die($c, ': not a Bivio::UI::Facade')
		unless UNIVERSAL::isa($c, 'Bivio::UI::Facade');
    Bivio::Die->die($c, ": did not call this module's new "
	    ." (non-production Facade?") unless ref($_CLASS_MAP{$clone});
    return $_CLASS_MAP{$clone};
}

sub _setup_request {
    my($self, $req) = @_;
    # Puts Bivio::UI::Facade on request with $self
    $req->put_durable(__PACKAGE__, $self);
    _trace($self) if $_TRACE;
    return $self;
}

1;
