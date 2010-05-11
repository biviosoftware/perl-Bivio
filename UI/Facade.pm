# Copyright (c) 2000-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;

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
my($_LFT) = b_use('UI.LocalFileType');
my($_C) = b_use('IO.Config');
my($_R) = b_use('Agent.Request');
my($_A) = b_use('IO.Alert');
my($_FN) = b_use('Type.FileName');
our($_TRACE);
my($_INITIALIZED) = 0;
my(%_CLASS_MAP);
my(%_URI_MAP);
my(%_COMPONENTS);
my(@_COMPONENTS);
my($_STATIC_COMPONENTS) = [qw(Email Icon View)];
$_C->register(my $_CFG = {
    default => $_C->REQUIRED,
    # Always ends in a trailing slash
    local_file_root => $_C->REQUIRED,
    want_local_file_cache => 1,
    mail_host => $_C->REQUIRED,
    http_suffix => $_C->REQUIRED,
});
my($_IS_FULLY_INITIALIZED) = 0;

sub as_string {
    my($self) = @_;
    return 'Facade[' . $self->simple_package_name . ']';
}

sub find_by_uri_or_domain {
    my($proto, $uri_or_domain) = @_;
    return $_CLASS_MAP{$_CFG->{default}}
	unless defined($uri_or_domain);
    $uri_or_domain = lc($uri_or_domain);
    foreach my $uri ($uri_or_domain, split(/\./, $uri_or_domain)) {
	return $_URI_MAP{$uri}
	    if $_URI_MAP{$uri};
    }
    return undef;
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
	$req_or_facade = $_R->get_current;
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
	    || b_die($simple_class, ': no such facade')
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
	. $_LFT->from_any($type)->get_path
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
    b_warn(
	$cfg->{local_file_root}, ': local_file_root is not a directory'
    ) unless $cfg->{local_file_root} && -d $cfg->{local_file_root};
    $cfg->{local_file_root} = $_FN->add_trailing_slash($cfg->{local_file_root});
    $_CFG = {%{$cfg}};
    return;
}

sub handle_unload_package {
    # Delete this class from cache
    return;
}

sub init_from_prior_group {
    my($self, $name) = @_;
    return sub {shift->handle_init_from_prior_group($name)};
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
    b_die(
	$_CFG->{default}, ': unable to find or load default Facade',
    ) unless ref($_CLASS_MAP{$_CFG->{default}});
    foreach my $f (sort(values(%_CLASS_MAP))) {
	foreach my $c (@$_STATIC_COMPONENTS) {
	    $f->put($c => Bivio::IO::ClassLoader->map_require(
		'FacadeComponent', $c
	    )->initialize_by_facade($f));
	}
	foreach my $c (@_COMPONENTS) {
	    b_die($f, ': ', $c, ': failed to load component')
	        unless $f->unsafe_get($c);
	}
	$f->set_read_only;
    }
    $_IS_FULLY_INITIALIZED = $partially ? 0 : 1;
    return;
}

sub matches_uri_or_domain {
    my($self, $uri_or_domain) = @_;
    return ($self->find_by_uri_or_domain($uri_or_domain) || 0) == $self;
}

sub is_fully_initialized {
    # Returns true if the Facade was has been completely initialized.
    return $_IS_FULLY_INITIALIZED;
}

sub make_groups {
    my($proto, $items) = @_;
    b_die('uneven number of items in array: ', $items)
        unless @$items % 2 == 0;
    return $proto->map_by_two(sub {[$_[0], $_[1]]}, $items);
}

sub matches_class_name {
    my($self, $class) = @_;
    return $self->simple_package_name eq $class;
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
    b_die($class, ': duplicate initialization')
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
    b_die($class, ': missing clone attribute')
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

    b_die($uri, ': duplicate uri for ', $class, ' and ',
	    ref($_URI_MAP{$uri}))
		if $_URI_MAP{$uri};
    _trace($class, ': uri=', $uri) if $_TRACE;

    # Initialize this instance's attributes
    $self->internal_put({
	uri => $uri,
	local_file_prefix => $_FN->add_trailing_slash($lfp),
	want_local_file_cache => $wlfc,
	is_production => $config->{is_production} ? 1 : 0,
	is_default => $_CFG->{default} eq $self->simple_package_name ? 1 : 0,
        cookie_domain => delete($config->{cookie_domain}),
    });
    _init_hosts($self, $config);
    foreach my $x (qw(
        uri local_file_prefix want_local_file_cache is_production
        mail_host http_host)) {
	delete($config->{$x});
    }

    # Load all components before initializing.  Modifies @ & %_COMPONENTS.
    foreach my $c (sort(keys(%$config))) {
	Bivio::IO::ClassLoader->map_require('FacadeComponent', $c)
	    ->handle_register;
    }
    _initialize($self, $config, $clone);

    # Store globally
    $_CLASS_MAP{$simple_class} = $_URI_MAP{$uri} = $self;
    return $self;
}

sub register {
    my(undef, $class, $required_components) = @_;
    # Registers new calling package.  I<required_components> is the list of
    # classes which this component uses or C<undef>.   I<required_components>
    # will be loaded dynamically.
    my($simple_class) = $class->simple_package_name;

    # Avoid recursion
    return
	if exists($_COMPONENTS{$simple_class});
    $_COMPONENTS{$simple_class} = undef;

    # Load prerequisites first, so they register.  This forces the
    # toposort.
    foreach my $c (@$required_components) {
	b_use('FacadeComponent', $c)->handle_register;
    }

    # Assert that this component is kosher.
    b_die($class, ': is not a FacadeComponent')
	unless b_use('UI.FacadeComponent')->is_subclass($class);
    b_die($class, ': already registered')
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
	b_die($uri_or_domain, ': is not a Request')
	    unless $_R->is_blessed($uri_or_domain);
	b_die('must not be called statically')
	    unless ref($proto);
	return _setup_request($proto, $uri_or_domain);
    }
    _trace('uri: ', $uri_or_domain) if $_TRACE;
    my($self) = $proto->find_by_uri_or_domain($uri_or_domain);
    unless ($self) {
	# Avoid repeated errors
	$self = $_URI_MAP{$uri_or_domain} = $_CLASS_MAP{$_CFG->{default}};
    }
    return _setup_request($self, $req);
}

sub unsafe_get_from_source {
    my(undef, $source) = @_;
    return $source->ureq(__PACKAGE__);
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
	    $_R->is_production
	        ? $config->{$_} || b_die(
		    $_, ': facade parameter missing in production')
		: _fixup_test_uri($self, $_CFG->{$_} || $_CFG->{http_suffix}),
	)), qw(http_host mail_host)),
    );
    return;
}

sub _initialize {
    my($self, $config, $clone) = @_;
    foreach my $c (@$_STATIC_COMPONENTS) {
	$self->put(
	    $c,
	    b_use('FacadeComponent', $c)->initialize_by_facade($self),
       );
    }
    foreach my $c (@_COMPONENTS) {
	# Get the config for this component (or force to exist)
	my($cfg) = $config->{$c} || {initialize => sub {}};
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
	b_die(
	    $self, ': ', $c,
	    ': missing component clone or initialize attributes',
	) unless $cc || $cfg->{initialize};

	# Create the instance, initialize, seal, and store.
	$self->put($c => $_COMPONENTS{$c}->new(
	    $self, $cc, $cfg->{initialize}));
	delete($config->{$c});
    }

    # Make sure everything in $config is valid.
    b_die($self, ': unknown config (modules not ',
	    ' FacadeComponents(?): ', $config) if %$config;

    return;
}

sub _load {
    my($clone) = @_;
    my($c) = b_use('Facade', $clone);
    b_die($c, ': not a ')
	unless __PACKAGE__->is_subclass($c);
    b_die($c, ": did not call this module's new (non-production Facade?")
	unless ref($_CLASS_MAP{$clone});
    return $_CLASS_MAP{$clone};
}

sub _setup_request {
    my($self, $req) = @_;
    $req->put_durable(
	__PACKAGE__, $self,
	'UI.Facade' => $self,
    );
    _trace($self) if $_TRACE;
    return $self;
}

1;
