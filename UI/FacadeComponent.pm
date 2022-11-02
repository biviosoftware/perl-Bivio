# Copyright (c) 2000-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent;
use strict;
use Bivio::Base 'UI.WidgetValueSource';

# C<Bivio::UI::FacadeComponent> manages a name space of typed values.
# The names are logically defined, e.g. I<page_bg> and I<http_host>.
# The values are type-dependent, e.g. I<Color> and I<Font>.  A
# FacadeComponent knows how to render the values in particular spaces,
# e.g. I<format_html> and I<format_mailto>.
#
# The names in a FacadeComponent are part of a I<group>.  This is used during
# initialization only.  Each group shares a single value, but has multiple names.
# Any name can be used to identify the value.  Names case-insensitive
# identifiers (alphanumerics and underscores), but lower-case names
# are more efficient on lookups.
#
# A FacadeComponent is initialized by a Facade.  It may be passed
# a I<clone> as a base initialization.  A I<value> is a hash_ref
# with tow keys: I<config> and I<names>, both of which are used to initialize
# the rest of the I<value>.  See
# L<internal_initialize_value|"internal_initialize_value"> for
# more details.

my($_IDI) = __PACKAGE__->instance_data_index;
my($_R) = b_use('IO.Ref');
my($_HANDLERS) = b_use('Biz.Registrar')->new;
b_use('IO.Config')->register(my $_CFG = {
    die_on_error => 0,
});

sub REGISTER_PREREQUISITES {
    return [];
}

sub UNDEF_CONFIG {
    # The configuration to be used when a value can't be found.  A
    # warning will be output and the value created by this configuration
    # will be returned.  The FacadeComponent should do something
    # "reasonable" in all possible cases, because a Facade failure
    # shouldn't cause an application failure, just a warning.
    #
    # Returns C<undef> by default.
    return undef;
}

sub as_string {
    my($self) = @_;
    return $self
        unless ref($self);
    return 'Facade['
        . $self->get_facade->unsafe_get('uri')
        . '].'
        . $self->simple_package_name;
}

sub assert_name {
    my($self, $name) = @_;
    # Dies if I<name> is invalid syntax.
    #
    # May be overridden by subclasses.  There is no real restriction on names,
    # but it is convenient to limit names to perl's /\w+/.
    $self->die($name, 'invalid name syntax')
        unless $name =~ /^\w+$/;
    return;
}

sub die {
    my($self, $value, @msg) = @_;
    # Dies with I<msg> and context.
    my($n) = ref($value) eq 'HASH' ? $value->{names} : $value;
    b_die($self, (defined($n) ? ('.', $n) : ()), ': ', @msg);
    # DOES NOT RETURN
}

sub exists {
    # True if the name exists.  Note: should only be used in rare circumstances.
    # The normal "get" and "format" routines handle undefined values properly.
    return defined(shift->[$_IDI]->{map}->{lc(shift(@_))}) ? 1 : 0;
}

sub format_css {
    return shift->get_value(@_);
}

sub get_error {
    my($self, $name, @msg) = @_;
    # Prints a warning or dies (depending on I<die_on_error>) and returns the
    # I<undef_value> for this component.
    #
    # If there is no I<msg>, will output "value not found" as the warning.
    push(@msg, 'value not found') unless @msg;
    _error($self, '.', $name, ': ', @msg);
    return $self->[$_IDI]->{undef_value};
}

sub get_facade {
    return shift->[$_IDI]->{facade};
}

sub get_from_facade {
    my($proto, $facade) = @_;
    return $facade->get($proto->simple_package_name);
}

sub get_from_source {
    my($proto, $source) = @_;
    return b_use('UI.Facade')->get_from_request_or_self($source)
        ->get($proto->simple_package_name);
}

sub group {
    my($self, $names, $value) = @_;
    my($fields) = $self->[$_IDI];
    _assert_writable($self);
    foreach my $name (ref($names) ? @$names : $names) {
        _assign(
            $self,
            $name,
            _initialize_value($self, {
                orig_config => $value,
                names => [lc($name)],
            }),
        );
    }
    return;
}

sub handle_call_autoload {
    my($self) = shift->get_from_source(b_use('Agent.Request')->get_current_or_die);
    return $self
        unless @_;
#TODO: This doesn't always work.  Really need a callback that does something by default
    return $self->get_value(@_);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub handle_init_from_prior_group {
    my($self, $name) = @_;
    return $_R->nested_copy((
        $self->[$_IDI]->{map}->{lc($name)}
        || $self->get_error($name, 'group value not previously defined')
    )->{config});
}

sub handle_register {
    my($proto) = @_;
    b_use('UI.Facade')->register($proto, $proto->REGISTER_PREREQUISITES);
    return;
}

sub initialization_complete {
    my($fields) = shift->[$_IDI];
    # Called by the Facade after all initialization is complete.
    # No more calls to L<group|"group">, etc. will
    # be accepted after this call.  Subclasses may override to
    # validate initialization is truly complete.
    #
    # Use this method to perform any I<cross value> initialization, e.g.
    # initializing internal reverse maps or cross-reference checks.  Before
    # this method is called, values may disappear after they are
    # initialized (see L<delete_group|"delete_group">).
    $fields->{read_only} = 1;
    return;
}

sub initialization_error {
    my($self, $value) = (shift, shift);
    # Prints a warning based on arguments.  May terminate.  See I<die_on_error>.
    _error($self, ' ', $value, ': ', @_);
    return;
}

sub internal_get_all {
    my($map) = shift->[$_IDI]->{map};
    # Returns a list of all values.  Use this routine only for initialization.
    # The array is generated each call.
    # This doesn't include the L<UNDEF_CONFIG|"UNDEF_CONFIG"> value.

    # Finds all group values.  The "value" is a hash_ref which is
    # uniquely named, so dups (other members of the group) are found
    # easily.
    my(%values);
    foreach my $v (values(%$map)) {
        $values{$v} = $v;
    }
    return [values(%values)];
}

sub internal_get_all_groups {
    # Returns a B<copy> of the group values.  Should only be used in
    # L<initialization_complete|"initialization_complete">.
    # Values have unique addresses (HASH(0xblabla)) so this trick works nicely
    my(%res) = map {
        ($_, $_);
    } values(%{shift->[$_IDI]->{map}});
    return [values(%res)];
}

sub internal_get_self {
    my($proto, $req_or_facade) = @_;
    return $proto
         if ref($proto) && !$req_or_facade;
    return $proto->get_from_source($req_or_facade);
}

sub internal_get_value {
    my($proto, $name, $req_or_facade) = @_;
    my($self) = $proto->internal_get_self($req_or_facade);
    return $self->get_error($self, ': passed undef as value to get')
        unless defined($name);
    return $self->internal_unsafe_lc_get_value($name)
        || _assign($self, $name, $self->get_error($name));
}

sub internal_unsafe_lc_get_value {
    my($self, $name) = @_;
    my($res) = $self->[$_IDI]->{map}->{lc($name)};
    return $_HANDLERS->do_filo(
        handle_internal_unsafe_lc_get_value => sub {
            return [$self, $name, $res];
        },
    ) || $res;
}

sub new {
    my($proto, $facade, $clone, $initialize) = @_;
    # Instantiate the component and set its facade.  I<clone> is used as the
    # base initialization, if supplied,
    # and then I<initialize> is called, if supplied.
    $proto->die($facade, 'missing or invalid facade')
        unless b_use('UI.Facade')->is_super_of($facade);
    my($self) = shift->SUPER::new;
    my($fields) = $self->[$_IDI] = {
        facade => $facade,
        map => {},
        dynamic_init => [],
        clone => $clone,
        initialize => $initialize,
        undef_value =>  _initialize_value(
            $self,
            {
                orig_config => $self->UNDEF_CONFIG,
                names => [],
            },
        ),
    };
    _init_from_clone($self, $clone);
    $initialize->($self)
        if $initialize;
    foreach my $value (@{$fields->{dynamic_init}}) {
        $value->{config} = $value->{orig_config}->($self);
        $self->internal_initialize_value($value);
    }
    $self->initialization_complete;
    return $self;
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub regroup {
    # Takes existing I<names> and re-associates with I<new_value>.
    # All names must exist.
    return shift->group(@_);
}

sub value {
    # Sets I<value> for the group which contains I<name>.
    #
    # #TODO: Arg order is bad.  Conflicts with group which is also bad...
    return shift->group(@_);
}

sub _assert_writable {
    my($self) = @_;
    # Called on "write" routines to make sure is writable.
    b_die(undef, 'attempt to modify after initialization')
        if $self->[$_IDI]->{read_only};
    return;
}

sub _assign {
    my($self, $name, $value) = @_;
    my($map) = $self->[$_IDI]->{map};
    # Assigns $value to $name in $map.  Does syntax checking.
    $name = lc($name);
    if ($map->{$name}) {
        # Delete name from previous map entry
        my($n) = $map->{$name}->{names};
        @$n = grep($name ne $_, @$n);
    }
    $self->assert_name($name);
    return $map->{$name} = $value;
}

sub _error {
    my(@msg) = @_;
    # Prints a warning or dies, depending on die_on_error
    Bivio::Die->die(@msg)
        if $_CFG->{die_on_error};
    Bivio::IO::Alert->warn(@msg);
    return;
}

sub _init_from_clone {
    my($self, $clone) = @_;
    # Calls the initialization depth first.
    return
        unless $clone;
    my($clone_fields) = $clone->[$_IDI];
    _init_from_clone($self, $clone_fields->{clone});
    $clone_fields->{initialize}->($self)
        if $clone_fields->{initialize};
    return;
}

sub _initialize_value {
    my($self, $value) = @_;
    $value->{config} = _initialize_value_config($self, $value);
    $self->internal_initialize_value($value);
    return $value;
}

sub _initialize_value_config {
    my($self, $value) = @_;
    return $_R->nested_copy($value->{orig_config})
        unless ref($value->{orig_config}) eq 'CODE';
    push(@{$self->[$_IDI]->{dynamic_init}}, $value);
    return $value->{orig_config}->($self);
}

1;
