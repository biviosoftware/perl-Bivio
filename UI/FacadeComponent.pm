# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent;
use strict;
$Bivio::UI::FacadeComponent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::FacadeComponent - maps logical names to facade-specific values

=head1 SYNOPSIS

    use Bivio::UI::FacadeComponent;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::FacadeComponent::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::FacadeComponent> manages a name space of typed values.
The names are logically defined, e.g. I<page_bg> and I<http_host>.
The values are type-dependent, e.g. I<Color> and I<Font>.  A
FacadeComponent knows how to render the values in particular spaces,
e.g. I<format_html> and I<format_mailto>.

The names in a FacadeComponent are part of a I<group>.  This is used during
initialization only.  Each group shares a single value, but has multiple names.
Any name can be used to identify the value.  Names case-insensitive
identifiers (alphanumerics and underscores), but lower-case names
are more efficient on lookups.

A FacadeComponent is initialized by a Facade.  It may be passed
a I<clone> as a base initialization.  A I<value> is a hash_ref
with at least one key, the I<config>, which is used to initialize
the rest of the I<value>.  See
L<internal_initialize_value|"internal_initialize_value"> for
more details.

=cut

=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 abstract UNDEF_CONFIG : any

The configuration to be used when a value can't be found.  A
warning will be output and the value created by this configuration
will be returned.  The FacadeComponent should do something
"reasonable" in all possible cases, because a Facade failure
shouldn't cause an application failure, just a warning.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::UI::Facade facade, Bivio::UI::FacadeComponent clone, sub initialize) : Bivio::UI::FacadeComponent

Instantiate the component and set its facade.  I<clone> is used as the
base initialization, if supplied,
and then I<initialize> is called, if supplied.

=cut

sub new {
    my($proto, $facade, $clone, $initialize) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    Bivio::IO::Alert->die($facade, ': missing or invalid facade')
		unless UNIVERSAL::isa($facade, 'Bivio::UI::Facade');

    # Set up our state
    my($fields) = $self->{$_PACKAGE} = {
	map => {},
	facade => $facade,
	clone => $clone,
	initialize => $initialize,
    };

    # Initialize undef value
    my($uv) = {config => $self->UNDEF_CONFIG};
    $self->internal_initialize_value($uv);
    $fields->{undef_value} = $uv;

    # Initialize from clone, self, and complete
    _init_from_clone($self, $clone);
    &$initialize($self) if $initialize;
    $self->initialization_complete;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_group_aliases"></a>

=head2 add_group_aliases(string group, string alias, ...)

Adds I<aliases> to I<group>.  I<aliases> must be new.
Use L<regroup|"regroup"> to reassociate a group of names.

=cut

sub add_group_aliases {
    my($self, $group) = (shift, shift);
    _assert_writable($self);

    my($map) = $self->{$_PACKAGE}->{map};
    Bivio::IO::Alert->die($self, '->', $group, ': group not found')
		unless $map->{$group};
    my($value) = $map->{$group};

    # Map the names
    foreach my $name (@_) {
	_assign($self, $map, $name, $value);
    }
    return;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

For warnings and debugging only, prints out the I<self> in nice string form.

=cut

sub as_string {
    my($self) = @_;
    return ref($self).'['.$self->get_facade->get('uri').']';
}

=for html <a name="bad_value"></a>

=head2 bad_value(hash_ref value, string name, string message, ...)

Prints a warning based on arguments.

=cut

sub bad_value {
    my($self, $value, $name) = (shift, shift, shift);
    my($fields) = $self->{$_PACKAGE};
    Bivio::IO::Alert->warn($self, '->', $name,
	    ' (', $value, '): ', @_);
    return;
}

=for html <a name="create_group"></a>

=head2 create_group(any value, string name, ...)

Creates a new group.  The I<name>s must be unique.  The I<value>
is defined by the subclass.  If it is a ref, ownership of I<value> is
taken by this module.

=cut

sub create_group {
    my($self, $value) = (shift, shift);
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};

    # Initialize the value
    $self->internal_initialize_value($value = {config => $value}, @_);

    # Map the names
    foreach my $name (@_) {
	_assign($self, $map, $name, $value);
    }
    return;
}

=for html <a name="get_facade"></a>

=head2 get_facade() : Bivio::UI::Facade

Returns the Facade to which this instance belongs.

=cut

sub get_facade {
    return shift->{$_PACKAGE}->{facade};
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string method) : any

Calls I<method> on I<self>.

=cut

sub get_widget_value {
    my($self, $method) = (shift, shift);
    # Delete leading -> for compatibility with "standard" get_widget_value
    $method =~ s/^\-\>//;
    return $self->$method(@_);
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Called by the Facade after all initialization is complete.
No more calls to L<create_group|"create_group">, etc. will
be accepted after this call.  Subclasses may override to
validate initialization is truly complete.

=cut

sub initialization_complete {
    my($fields) = shift->{$_PACKAGE};
    $fields->{read_only} = 1;
    return;
}

=for html <a name="internal_get_value"></a>

=head2 static internal_get_value(string name, Bivio::Collection::Attributes req_or_facade) : hash_ref

=head2 internal_get_value(string name) : hash_ref

Returns the value of for I<name>.  If not found, writes a
warning and returns the value configured by
L<UNDEF_CONFIG|"UNDEF_CONFIG">.  Adds invalid names to the
map (same group as undef_value), so that we only get one error.

If called statically, it expects to find $proto as an
attribute of I<req_or_facade>.

=cut

sub internal_get_value {
    my($proto, $name, $req) = @_;

    # If a reference, then dynamic.  Just get from instance.
    # Otherwise, $req and $facade behave similarly; they are both
    # Collection::Attributes with the class as the attribute name.
    my($self) = ref($proto) ? $proto : $req->get($proto);

    my($fields) = $self->{$_PACKAGE};

    # Return undef_value if passed in undef.  Shouldn't happen...
    unless (defined($name)) {
	Bivio::IO::Alert->warn($self, ': passed undef');
	return $fields->{undef_value};
    }

    # Look up case-sensitively
    my($map) = $fields->{map};
    return $map->{$name} if $map->{$name};

    # Try lower
    $name = lc($name);
    return $map->{$name} if $map->{$name};

    # Not found
    Bivio::IO::Alert->warn($self, ': ', $name, ': value not found');

    # Add to the map as undef and return
    return $map->{$name} = $fields->{undef_value};
}

=for html <a name="internal_unsafe_get_value"></a>

=head2 internal_unsafe_get_value(string name) : hash_ref

Looks up the name simply.  If not found, returns undef.

=cut

sub internal_unsafe_get_value {
    return shift->{$_PACKAGE}->{map}->{lc(shift(@_))};
}

=for html <a name="internal_initialize_value"></a>

=head2 abstract internal_initialize_value(hash_ref value, string name)

Called to initialize the properties of a value.  The I<config>
property of the hash_ref is set, i.e. this class will call
its subclasses as follows:

    $self->internal_initialize_value({
        config => $value
    });

The value of I<config> must not be modified, as it may be copied
from the I<clone>.

If there is an error, subclasses should try to recover outputting
a warning using I<name>.

=cut

=for html <a name="regroup"></a>

=head2 regroup(any new_value, string name, ...)

Takes existing I<names> and re-associates with I<new_value>.
All names must exist.  Use L<add_group_aliases|"add_group_aliases">
to create new names in an existing group.

=cut

sub regroup {
    my($self, $new_value) = (shift, shift);
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};

    # Delete the names from the map
    foreach my $name (@_) {
	Bivio::IO::Alert->die($self, '->', $name, ': name not found')
		unless $map->{$name};
	delete($map->{$name});
    }

    # Now can just create a new group
    $self->create_group($new_value, @_);
    return;
}

=for html <a name="set_group_value"></a>

=head2 set_group_value(string name, any value)

Sets I<value> for the group which contains I<name>.

=cut

sub set_group_value {
    my($self, $name, $value) = @_;
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};
    Bivio::IO::Alert->die($self, '->', $name, ': group not found')
		unless $map->{$name};

    # Clear out old state and reinitialize
    my($old_value) = $map->{$name};
    %$old_value = (config => $value);
    $self->internal_initialize_value($old_value, $name);
    return;
}

#=PRIVATE METHODS

# _assert_writable(Bivio::UI::FacadeComponent self)
#
# Called on "write" routines to make sure is writable.
#
sub _assert_writable {
    my($self) = @_;
    Bivio::IO::Alert->die($self, ': attempt to modify after initialization')
		if $self->{$_PACKAGE}->{read_only};
    return;
}

# _assign(Bivio::UI::FacadeComponent self, hash_ref map, string name, hash_ref value)
#
# Assigns $value to $name in $map.  Does syntax checking.
#
sub _assign {
    my($self, $map, $name, $value) = @_;
    $name = lc($name);
    Bivio::IO::Alert->die($self, '->', $name, ': duplicate name')
		if $map->{$name};
    Bivio::IO::Alert->die($self, '->', $name, ': invalid name syntax')
		unless $name =~ /^\w+$/;
    $map->{$name} = $value;
    return;
}

# _init_from_clone(Bivio::UI::FacadeComponent self, Bivio::UI::FacadeComponent clone)
#
# Calls the initialization depth first.
#
sub _init_from_clone {
    my($self, $clone) = @_;
    return unless $clone;
    my($clone_fields) = $clone->{$_PACKAGE};
    _init_from_clone($self, $clone_fields->{clone});
    &{$clone_fields->{initialize}}($self);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
