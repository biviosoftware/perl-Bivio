# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent;
use strict;
$Bivio::UI::FacadeComponent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::FacadeComponent::VERSION;

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
with tow keys: I<config> and I<names>, both of which are used to initialize
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
use Bivio::Die;

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
    Bivio::Die->die($facade, ': missing or invalid facade')
		unless UNIVERSAL::isa($facade, 'Bivio::UI::Facade');

    # Set up our state
    my($fields) = $self->{$_PACKAGE} = {
	map => {},
	facade => $facade,
	clone => $clone,
	initialize => $initialize,
    };

    return $self if _init_from_parent($self);

    # Initialize undef value
    my($uv) = {config => $self->UNDEF_CONFIG, names => []};
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

=for html <a name="as_string"></a>

=head2 as_string() : string

For warnings and debugging only, prints out the I<self> in nice string form.

=cut

sub as_string {
    my($self) = @_;
    return ref($self).'['.$self->get_facade->get('uri').']';
}

=for html <a name="bad_value"></a>

=head2 bad_value(hash_ref value, string message, ...)

Prints a warning based on arguments.

=cut

sub bad_value {
    my($self, $value) = (shift, shift, shift);
    Bivio::IO::Alert->warn($self, ' ', $value, ': ', @_);
    return;
}

=for html <a name="exists"></a>

=head2 exists(string name) : boolean

True if the name exists.  Note: should only be used in rare circumstances.
The normal "get" and "format" routines handle undefined values properly.

=cut

sub exists {
    return defined(shift->{$_PACKAGE}->{map}->{lc(shift(@_))}) ? 1 : 0;
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

=for html <a name="group"></a>

=head2 group(string name, any value)

=head2 group(array_ref names, any value)

Creates a new group.  The I<name>s must be unique.  The I<value>
is defined by the subclass.  If it is a ref, ownership of I<value> is
taken by this module.

=cut

sub group {
    my($self, $names, $value) = @_;
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};
    $names = ref($names) ? $names : [$names];

    # Initialize the value
    $value = {config => $value, names => $names};
    $self->internal_initialize_value($value);

    # Map the names
    foreach my $name (@$names) {
	_assign($self, $map, $name, $value);
    }
    return;
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Called by the Facade after all initialization is complete.
No more calls to L<group|"group">, etc. will
be accepted after this call.  Subclasses may override to
validate initialization is truly complete.

=cut

sub initialization_complete {
    my($fields) = shift->{$_PACKAGE};
    $fields->{read_only} = 1;
    return;
}

=for html <a name="internal_get_all"></a>

=head2 internal_get_all() : array_ref

Returns a list of all values.  Use this routine only for initialization.
The array is generated each call.
This doesn't include the L<UNDEF_CONFIG|"UNDEF_CONFIG"> value.

=cut

sub internal_get_all {
    my($map) = shift->{$_PACKAGE}->{map};

    # Finds all group values.  The "value" is a hash_ref which is
    # uniquely named, so dups (other members of the group) are found
    # easily.
    my(%values);
    foreach my $v (values(%$map)) {
	$values{$v} = $v;
    }
    return [values(%values)];
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

=head2 abstract internal_initialize_value(array_ref names, hash_ref value)

Called to initialize the properties of a value.  The I<config>
property of the hash_ref is set, i.e. this class will call
its subclasses as follows:

    $self->internal_initialize_value({
        config => $value
        names => $names,
    });

The value of I<config> and I<names> must not be modified,
as they may be copied from the I<clone>.

If there is an error, subclasses should try to recover outputting
a warning using I<names>.  Note that I<names> may be empty, in
the case of L<UNDEF_CONFIG|"UNDEF_CONFIG">.

=cut

=for html <a name="regroup"></a>

=head2 regroup(string name, any new_value)

=head2 regroup(array_ref names, any new_value)

Takes existing I<names> and re-associates with I<new_value>.
All names must exist.  Use L<add_group_aliases|"add_group_aliases">
to create new names in an existing group.

=cut

sub regroup {
    my($self, $names, $new_value) = @_;
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};
    $names = ref($names) ? $names : [$names];

    # Delete the names from the map
    foreach my $name (@$names) {
	Bivio::Die->die($self, '->', $name, ': name not found')
		unless $map->{$name};
	delete($map->{$name});
    }

    # Now can just create a new group
    $self->group($names, $new_value);
    return;
}

=for html <a name="value"></a>

=head2 value(string name, any value)

Sets I<value> for the group which contains I<name>.

#TODO: Arg order is bad.  Conflicts with group which is also bad...

=cut

sub value {
    my($self, $name, $value) = @_;
    _assert_writable($self);
    my($map) = $self->{$_PACKAGE}->{map};
    Bivio::Die->die($self, '->', $name, ': group not found')
		unless $map->{$name};

    # Clear out old state and reinitialize
    my($old_value) = $map->{$name};
    %$old_value = (config => $value, names => $old_value->{names});
    $self->internal_initialize_value($old_value);
    return;
}

#=PRIVATE METHODS

# _assert_writable(Bivio::UI::FacadeComponent self)
#
# Called on "write" routines to make sure is writable.
#
sub _assert_writable {
    my($self) = @_;
    Bivio::Die->die($self, ': attempt to modify after initialization')
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
    Bivio::Die->die($self, '->', $name, ': duplicate name')
		if $map->{$name};
    Bivio::Die->die($self, '->', $name, ': invalid name syntax')
		unless $name =~ /^\w+$/;
    $map->{$name} = $value;
    return;
}

# _init_from_clone(self, Bivio::UI::FacadeComponent clone)
#
# Calls the initialization depth first.
#
sub _init_from_clone {
    my($self, $clone) = @_;
    return unless $clone;
    my($clone_fields) = $clone->{$_PACKAGE};
    _init_from_clone($self, $clone_fields->{clone});
    &{$clone_fields->{initialize}}($self) if $clone_fields->{initialize};
    return;
}

# _init_from_parent(self) : self
#
# Copy all the fields and groups verbatim.  Full sharing.
#
sub _init_from_parent {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    # No clone or have explicit initialize, need to copy
    return 0 unless $fields->{clone} && !$fields->{initialize};

    # Cloning from my parent?
    my($parent) = $fields->{facade}->unsafe_get('parent');
    my($clone_fields) = $fields->{clone}->{$_PACKAGE};
    return 0 unless $parent && $parent == $clone_fields->{facade};

    # Copy fields and groups
    foreach my $field (qw(map undef_value read_only)) {
	$fields->{$field} = $clone_fields->{$field};
    }
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
