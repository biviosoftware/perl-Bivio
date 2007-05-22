# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent;
use strict;
$Bivio::UI::FacadeComponent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::FacadeComponent::VERSION;

=head1 NAME

Bivio::UI::FacadeComponent - maps logical names to facade-specific values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::FacadeComponent;

=cut

=head1 EXTENDS

L<Bivio::UI::WidgetValueSource>

=cut

use Bivio::UI::WidgetValueSource;
@Bivio::UI::FacadeComponent::ISA = ('Bivio::UI::WidgetValueSource');

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

=head2 UNDEF_CONFIG : any

The configuration to be used when a value can't be found.  A
warning will be output and the value created by this configuration
will be returned.  The FacadeComponent should do something
"reasonable" in all possible cases, because a Facade failure
shouldn't cause an application failure, just a warning.

Returns C<undef> by default.

=cut

sub UNDEF_CONFIG {
    return undef;
}

#=IMPORTS
use Bivio::IO::Config;
use Bivio::Die;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_DIE_ON_ERROR) = 0;
Bivio::IO::Config->register({
    die_on_error => $_DIE_ON_ERROR,
});

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
    my($self) = $proto->SUPER::new;
    $proto->die($facade, 'missing or invalid facade')
	    unless UNIVERSAL::isa($facade, 'Bivio::UI::Facade');

    # Set up our state
    my($fields) = $self->[$_IDI] = {
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
    return $self unless ref($self);
    return 'Facade['.$self->get_facade->unsafe_get('uri').'].'
	    .$self->simple_package_name;
}

=for html <a name="assert_name"></a>

=head2 static assert_name(string name)

Dies if I<name> is invalid syntax.

May be overridden by subclasses.  There is no real restriction on names,
but it is convenient to limit names to perl's /\w+/.

=cut

sub assert_name {
    my($self, $name) = @_;
    $self->die($name, 'invalid name syntax') unless $name =~ /^\w+$/;
    return;
}

=for html <a name="die"></a>

=head2 die(hash_ref value, string msg, ...)

=head2 die(any entity, string msg, ...)

Dies with I<msg> and context.

=cut

sub die {
    my($self, $value, @msg) = @_;
    my($n) = ref($value) eq 'HASH' ? $value->{names} : $value;
    Bivio::Die->die($self, (defined($n) ? ('.', $n) : ()), ': ', @msg);
    # DOES NOT RETURN
}

=for html <a name="exists"></a>

=head2 exists(string name) : boolean

True if the name exists.  Note: should only be used in rare circumstances.
The normal "get" and "format" routines handle undefined values properly.

=cut

sub exists {
    return defined(shift->[$_IDI]->{map}->{lc(shift(@_))}) ? 1 : 0;
}

=for html <a name="format_css"></a>

=head2 static format_css(string name, .., Bivio::Collection::Attributes req_or_facade) : string

=head2 format_css(string name, ... ) : array

=cut

sub format_css {
    return shift->get_value(@_);
}

=for html <a name="get_error"></a>

=head2 get_error(any name, string msg, ...) : any

Prints a warning or dies (depending on I<die_on_error>) and returns the
I<undef_value> for this component.

If there is no I<msg>, will output "value not found" as the warning.

=cut

sub get_error {
    my($self, $name, @msg) = @_;
    push(@msg, 'value not found') unless @msg;
    _error($self, '.', $name, ': ', @msg);
    return $self->[$_IDI]->{undef_value};
}

=for html <a name="get_facade"></a>

=head2 get_facade() : Bivio::UI::Facade

Returns the Facade to which this instance belongs.

=cut

sub get_facade {
    return shift->[$_IDI]->{facade};
}

=for html <a name="get_from_source"></a>

=head2 static get_from_source(any source) : self

Returns this instance off of the facade on source.

=cut

sub get_from_source {
    my($proto, $source) = @_;
    return Bivio::UI::Facade->get_from_request_or_self($source->get_request)
	    ->get($proto->simple_package_name);
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
    my($map) = $self->[$_IDI]->{map};
    $names = ref($names) ? $names : [$names];

    # Initialize the value
    $value = {config => $value, names => $names};
    _initialize_value($self, $value);

    # Map the names
    foreach my $name (@$names) {
	_assign($self, $map, $name, $value);
    }
    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item die_on_error : boolean [0]

If true, L<get_error|"get_error"> and
L<initialization_error|"initialization_error"> will die
on errors instead of just warning.  Use for debugging
problems.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DIE_ON_ERROR = $cfg->{die_on_error};
    return;
}

=for html <a name="handle_register"></a>

=head2 static abstract handle_register()

Tells the component to handle_register with
L<Bivio::UI::Facade|Bivio::UI::Facade>.  Can also perform global
initialization.

=cut

$_ = <<'}'; # For emacs
sub handle_register {
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Called by the Facade after all initialization is complete.
No more calls to L<group|"group">, etc. will
be accepted after this call.  Subclasses may override to
validate initialization is truly complete.

Use this method to perform any I<cross value> initialization, e.g.
initializing internal reverse maps or cross-reference checks.  Before
this method is called, values may disappear after they are
initialized (see L<delete_group|"delete_group">).

=cut

sub initialization_complete {
    my($fields) = shift->[$_IDI];
    $fields->{read_only} = 1;
    return;
}

=for html <a name="initialization_error"></a>

=head2 initialization_error(hash_ref value, string message, ...)

Prints a warning based on arguments.  May terminate.  See I<die_on_error>.

=cut

sub initialization_error {
    my($self, $value) = (shift, shift);
    _error($self, ' ', $value, ': ', @_);
    return;
}

=for html <a name="internal_get_all"></a>

=head2 internal_get_all() : array_ref

Returns a list of all values.  Use this routine only for initialization.
The array is generated each call.
This doesn't include the L<UNDEF_CONFIG|"UNDEF_CONFIG"> value.

=cut

sub internal_get_all {
    my($map) = shift->[$_IDI]->{map};

    # Finds all group values.  The "value" is a hash_ref which is
    # uniquely named, so dups (other members of the group) are found
    # easily.
    my(%values);
    foreach my $v (values(%$map)) {
	$values{$v} = $v;
    }
    return [values(%values)];
}

=for html <a name="internal_get_all_groups"></a>

=head2 internal_get_all_groups() : array_ref

Returns a B<copy> of the group values.  Should only be used in
L<initialization_complete|"initialization_complete">.

=cut

sub internal_get_all_groups {
    # Values have unique addresses (HASH(0xblabla)) so this trick works nicely
    my(%res) = map {
	($_, $_);
    } values(%{shift->[$_IDI]->{map}});
    return [values(%res)];
}

=for html <a name="internal_get_self"></a>

=head2 internal_get_self(Bivio::Collection::Attributes req_or_facade) : self

Returns this Facade component by searching I<req_or_facade> or
current request or just if called with self.

Dies if it can't find self.

=cut

sub internal_get_self {
    my($proto, $req_or_facade) = @_;

    # $req_or_facade is set to Request->get_current, if it wasn't passed
    # and we need it.
    unless ($req_or_facade) {
	return $proto if ref($proto);
	$req_or_facade = Bivio::Agent::Request->get_current;
    }

    # If a reference, then dynamic.  Just get from instance.
    # Otherwise, $req and $facade behave similarly; they are both
    # Collection::Attributes with the class as the attribute name.
    return (
	$req_or_facade->isa('Bivio::UI::Facade')
	    ? $req_or_facade
	    : $req_or_facade->get_request->get('Bivio::UI::Facade')
	)->get($proto->simple_package_name);
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
    my($proto, $name, $req_or_facade) = @_;
    my($self) = $proto->internal_get_self($req_or_facade);
    my($fields) = $self->[$_IDI];

    # Return undef_value if passed in undef.  Shouldn't happen...
    return $self->get_error($self, ': passed undef as value to get')
	    unless defined($name);

    # Look up case-sensitively
    my($map) = $fields->{map};
    return $map->{$name} if $map->{$name};

    # Try lower
    $name = lc($name);
    return $map->{$name} if $map->{$name};

    # Add to the map as undef and return
    return $map->{$name} = $self->get_error($name);
}

=for html <a name="internal_initialize_value"></a>

=head2 abstract internal_initialize_value(hash_ref value)

Called to initialize the properties of a value.  The I<config>
property of the hash_ref is set, i.e. this class will call
its subclasses as follows:

    $self->internal_initialize_value({
        config => $value
        names => $names,
    });

The value of I<config> and I<names> must not be modified,
as they may be copied from the I<clone>.

Errors are output by L<die|"die">

=cut

$_ = <<'}'; # for emacs
sub internal_initialize_value {
}

=for html <a name="internal_unsafe_lc_get_value"></a>

=head2 internal_unsafe_lc_get_value(string name) : hash_ref

Looks up the name simply.  If not found, returns undef.
I<name> is assumed to be already downcased.

=cut

sub internal_unsafe_lc_get_value {
    my($self, $name) = @_;
    return $self->[$_IDI]->{map}->{$name};
}

=for html <a name="regroup"></a>

=head2 regroup(string name, any new_value)

=head2 regroup(array_ref names, any new_value)

Takes existing I<names> and re-associates with I<new_value>.
All names must exist.

=cut

sub regroup {
    return shift->group(@_);
}

=for html <a name="value"></a>

=head2 value(string name, any value)

Sets I<value> for the group which contains I<name>.

#TODO: Arg order is bad.  Conflicts with group which is also bad...

=cut

sub value {
    return shift->group(@_);
}

#=PRIVATE METHODS

# _assert_writable(Bivio::UI::FacadeComponent self)
#
# Called on "write" routines to make sure is writable.
#
sub _assert_writable {
    my($self) = @_;
    Bivio::Die->die(undef, 'attempt to modify after initialization')
		if $self->[$_IDI]->{read_only};
    return;
}

# _assign(Bivio::UI::FacadeComponent self, hash_ref map, string name, hash_ref value)
#
# Assigns $value to $name in $map.  Does syntax checking.
#
sub _assign {
    my($self, $map, $name, $value) = @_;
    $name = lc($name);
    if ($map->{$name}) {
	# Delete name from previous map entry
	my($n) = $map->{$name}->{names};
	@$n = grep($name ne $_, @$n);
    }
    $self->assert_name($name);
    $map->{$name} = $value;
    return;
}

# _error(array msg)
#
# Prints a warning or dies, depending on die_on_error
#
sub _error {
    my(@msg) = @_;
    Bivio::Die->die(@msg) if $_DIE_ON_ERROR;
    Bivio::IO::Alert->warn(@msg);
    return;
}

sub _initialize_value {
    my($self, $value) = @_;
    $value->{config} = $value->{config}->($self)
	if ref($value->{config}) eq 'CODE';
    return $self->internal_initialize_value($value);
}

# _init_from_clone(self, Bivio::UI::FacadeComponent clone)
#
# Calls the initialization depth first.
#
sub _init_from_clone {
    my($self, $clone) = @_;
    return unless $clone;
    my($clone_fields) = $clone->[$_IDI];
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
    my($fields) = $self->[$_IDI];
    # No clone or have explicit initialize, need to copy
    return 0 unless $fields->{clone} && !$fields->{initialize};

    # Cloning from my parent?
    my($parent) = $fields->{facade}->unsafe_get('parent');
    my($clone_fields) = $fields->{clone}->[$_IDI];
    return 0 unless $parent && $parent == $clone_fields->{facade};

    # Copy fields and groups
    foreach my $field (qw(map undef_value read_only)) {
	$fields->{$field} = $clone_fields->{$field};
    }
    return 1;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
