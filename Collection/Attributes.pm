# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Collection::Attributes;
use strict;
use base 'Bivio::UI::WidgetValueSource';
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

# C<Bivio::Collection::Attributes> provides a useful wrapper around a
# hash of values.
#
# It can be subclassed to allow arbitrary named attributes
# without polluting a class's internal field name space.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_READ_ONLY_ERROR) = 'attempt to modify read-only instance';

# Not likely to be an attribute. NOT CHECKED.
my($_READ_ONLY_ATTR) = "$;";

sub ancestral_get {
    my($self, $name, $default) = @_;
    # Returns the named attribute if found.  If not found, checks I<parent>'s
    # attributes (recursively).  If none of the ancestors have the attribute, dies if
    # I<default> not supplied or returns default.
    my($s) = $self;
    while ($s) {
	return $s->get($name)
	    if $s->has_keys($name);
	$s = $s->unsafe_get('parent');
    }
    return $default
	if int(@_) > 2;
    _die($self, $name, ': ancestral attribute not found');
    # DOES NOT RETURN
}

sub ancestral_has_keys {
     my($self, @names) = @_;
    # Returns true if all the named attributes exist (but may be C<undef>) in this
    # instance or its ancestors.
     _die($self, 'missing arguments') unless @names;
     my($fields) = $self->[$_IDI];
     while (@names) {
 	# Top of array checked first, since we're splicing as we go
 	for (my($i) = $#names; $i >= 0; $i--) {
 	    splice(@names, $i, 1) if exists($fields->{$names[$i]});
  	}
  	return @names ? 0 : 1 unless defined($fields->{parent});
  	$fields = $fields->{parent}->[$_IDI];
      }
      return 1;
}

sub are_defined {
    # Returns true if all attributes are defined.
    foreach my $v (shift->unsafe_get(@_)) {
	return 0
	    unless defined($v);
    }
    return 1;
}

sub delete {
    my($self) = shift;
    # Removes the named attribute(s) from the map.  They needn't exist.
    my($fields) = _writable($self);
    map(delete($fields->{$_}), @_);
    return $self;
}

sub delete_all {
    my($self) = @_;
    # Removes all the parameters.
    _writable($self);
    $self->[$_IDI] = {};
    return $self;
}

sub delete_all_by_regexp {
    my($self, $pattern) = @_;
    # Deletes all keys matching I<pattern>.
    _writable($self);
    return $self->delete(
	@{$self->map_each(
	    sub {
		my(undef, $k) = @_;
		return $k =~ /$pattern/ ? $k : ();
	    }
	)},
    );
}

sub dump {
    my($self) = @_;
    # For debugging, dumps the current state to trace output. One level only.
    if ($_TRACE) {
	my($dump) = "\n";
	foreach my $k (sort(@{$self->get_keys})) {
	    my($value) = $self->get($k);
	    $dump .= "\t$k => ".(defined($value) ? $value : 'undef')."\n";
	}
	_trace($dump);
    }
    return;
}

sub echo {
    my($self) = shift;
    # Returns its arguments.  Used for literal widget values.
    return shift if int(@_) <= 1;
    _die($self, 'expecting an array context') unless wantarray;
    return @_;
}

sub get {
    my($self) = shift;
    # Returns the named value(s).  If I<key> doesn't exist, C<die> is called.  Use
    # L<has_keys|"has_keys"> to test for existence.
    my($fields) = $self->[$_IDI];
    return $self->return_scalar_or_array(map(
	exists($fields->{$_}) ? $fields->{$_}
	    : _die($self, $_, ": attribute doesn't exist"),
	@_));
}

sub get_by_regexp {
    return _unsafe_get_by_regexp(0, @_);
}

sub get_if_defined_else_put {
    return shift->put_unless_defined(@_)
	->get(map($_[2 * $_], 0 .. (@_/2 - 1)));
}

sub get_if_exists_else_put {
    # Returns value of I<key> if it exists.  Otherwise, calls I<value> if it
    # is a code_ref or just puts I<value>.
    #
    # See also put_unless_exists.
    #
    # Returns the gotten or computed value.
    return shift->put_unless_exists(@_)
	->get(map($_[2 * $_], 0 .. (@_/2 - 1)));
}

sub get_keys {
    # Returns the list of keys.
    return [grep($_ ne $_READ_ONLY_ATTR, keys(%{shift->[$_IDI]}))];
}

sub get_nested {
    # Looks up I<name> and indexes with I<subname>, if supplied.  Continues with
    # subnames.  Works both with hash_refs and array_refs.  There is type checking on
    # I<subname> if the value is an array_ref.
    #
    # Similar to L<get_widget_value|"get_widget_value">, but not as complex.
    #
    # Note that the value returned may be C<undef> if the nested lookup
    # exists, but is C<undef>.
    return _get_nested(@_);
}

sub get_or_default {
    my($self, $name, $default) = @_;
    Bivio::IO::Alert->warn_deprecated(
	$name, ': code_ref will be executed in in a future version'
    ) if ref($default) eq 'CODE';
    my($fields) = $self->[$_IDI];
    return exists($fields->{$name}) ? $fields->{$name} : $default;
}

sub get_shallow_copy {
    my($self, $key_re) = @_;
    # Return a shallow copy of the attributes.
    my($k) = $key_re ? [grep($_ =~ $key_re, @{$self->get_keys})]
	: $self->get_keys;
    return {map((shift(@$k) => $_), $self->get(@$k))};
}

sub has_keys {
    my($fields) = shift->[$_IDI];
    # Returns 1 if the named keys exist, otherwise 0.
    map {exists($fields->{$_}) || return 0} @_;
    return 1;
}

sub internal_clear_read_only {
    my($self) = @_;
    # Reset is_read_only.  Use with caution.
    _die($self, "protected method")
	unless caller(0)->isa(__PACKAGE__);
    delete($self->[$_IDI]->{$_READ_ONLY_ATTR});
    return $self;
}

sub internal_get {
    my($self) = @_;
    # Returns the attributes as a hash.  Only subclasses may call this
    # method (enforced).
    #
    # Modifying the hash will modify the attributes.
    #
    # Not allowed if read-only.
    _die($self, "protected method")
	unless caller(0)->isa(__PACKAGE__);
    return _writable($self);
}

sub internal_put {
    my($self, $fields) = @_;
    # Replaces all the attributes with the hash.  Only subclasses may call this
    # method (enforced).
    #
    # Modifying the hash will modify the attributes.
    _die($self, "protected method")
	unless caller(0)->isa(__PACKAGE__);
    _writable($self);
    $self->[$_IDI] = $fields;
    return $self;
}

sub is_empty {
    # Returns whether any attributes in the map.
    return @{shift->get_keys} ? 1 : 0;
}

sub is_read_only {
    # Returns true if the view is READ_ONLY.
    return shift->[$_IDI]->{$_READ_ONLY_ATTR} ? 1 : 0;
}

sub map_each {
    my($self, $map_each_handler) = @_;
    # Calls L<map_each_handler|"map_each_handler"> for each (key, value) attribute
    # pair.  Values are copied with L<get_shallow_copy|"get_shallow_copy">.  You
    # cannot modify them in place, but if a value is a reference, you can modify what
    # it points to.
    #
    # Keys are sorted.
    #
    # Returns the aggregated result of L<map_each_handler|"map_each_handler">
    # as an array_ref.
    my($c) = $self->get_shallow_copy;
    return [map($map_each_handler->($self, $_, $c->{$_}), sort(keys(%$c)))];
}

sub new {
    my($proto, $map) = @_;
    # Creates an instance with I<map>. The constructor doesn't copy
    # the map, so don't modify the hash after invoking this.
    my($self) = $proto->SUPER::new;
    $map = {} unless ref($map) eq 'HASH';
    $self->[$_IDI] = $map;
    return $self;
}

sub put {
    my($self, $args) = _even(\@_);
    # Adds or replaces the named value(s).
    #
    # Returns I<self>.
    my($fields) = _writable($self);
    while (@$args) {
	my($k, $v) = (shift(@$args), shift(@$args));
	$fields->{$k} = $v;
    }
    return $self;
}

sub put_unless_exists {
    my($self, $args) = _even(\@_);
    # If I<key> exists, does nothing.  Otherwise, puts the result of a call to
    # I<value> if it is a code_ref and or just puts I<value> if it isn't a code_ref.
    _writable($self);
    while (@$args) {
	my($k, $v) = (splice(@$args, 0, 2));
	$self->put($k => ref($v) eq 'CODE' ? $v->() : $v)
	    unless $self->has_keys($k);
    }
    return $self;
}

sub put_unless_defined {
    my($self, $args) = _even(\@_);
    _writable($self);
    while (@$args) {
	my($k, $v) = (splice(@$args, 0, 2));
	$self->put($k => ref($v) eq 'CODE' ? $v->() : $v)
	    unless defined($self->unsafe_get($k));
    }
    return $self;
}

sub set_read_only {
    my($self) = @_;
    # Delete, put, etc. cannot be called.
    $self->[$_IDI]->{$_READ_ONLY_ATTR} = 1;
    return $self;
}

sub unsafe_get {
    my($self) = shift(@_);
    # Returns the named value(s).  If I<key> doesn't exist, C<undef> is returned
    # in its place.
    my($fields) = $self->[$_IDI];
    return $self->return_scalar_or_array(map($fields->{$_}, @_))
}

sub unsafe_get_by_regexp {
    return _unsafe_get_by_regexp(1, @_);
}

sub unsafe_get_nested {
    # Looks up I<name> and indexes with I<subname>, if supplied.  Continues with
    # subnames.  Works with objects of this class, hash_refs and, array_refs.  There
    # are type assertions on I<subname> if the value is an array_ref, or that the
    # thing being indexed is indexable.
    #
    # Similar to L<get_widget_value|"get_widget_value">, but not as complex.
    #
    # Will return C<undef> if the value doesn't exist at any level.
    return _get_nested(@_);
}

sub unsafe_get_widget_value_by_name {
    my($self, $name) = @_;
    # Returns:
    #
    #     ($self->unsafe_get($name), $self->exists($name))
    return ($self->unsafe_get($name), $self->has_keys($name));
}

sub _die {
    my($self, @msg) = @_;
    # Terminates with nice message
    my($sub) = (caller(1))[3];
    $sub =~ s/.*://;
    Bivio::IO::Alert->bootstrap_die($self, '->', $sub, ': ', @msg);
    # DOES NOT RETURN
}

sub _even {
    my($args) = @_;
    my($self) = shift(@$args);
    _die($self, "must be an even number of parameters")
	unless @$args % 2 == 0;
    return ($self, $args);
}

sub _get_nested {
    my($self, @names) = @_;
    # Does work of get_nested and unsafe_get_nested
    my($method) = $self->my_caller;
    my($v) = $self;
    while (@names) {
	my($name) = shift(@names);
	if (defined($v) && $v eq $self) {
	    if ($v->has_keys($name)) {
		$v = $v->unsafe_get($name);
		next;
	    }
	}
	elsif (ref($v) eq 'HASH') {
	    if (exists($v->{$name})) {
		$v = $v->{$name};
		next;
	    }
	}
	elsif (ref($v) eq 'ARRAY') {
	    _die($self, $name, ": not an array index ", \@names)
		unless $name =~ /^\d+$/;
	    if ($name <= $#$v) {
		$v = $v->[$name];
		next;
	    }
	}
	elsif (ref($v) && UNIVERSAL::isa($v, __PACKAGE__)) {
	    return $v->$method($name, @names);
	}
	else {
	    return undef
		if  $method =~ /unsafe/ && !defined($v);
	    _die($self, "can't index \"", $v, '" at name "',
		    $name, '" ', \@names);
	}
	return $method =~ /unsafe/
	    ? undef
	    : _die($self, $name, ": attribute doesn't exist ",
		   @names ? \@names: ());
    }
    return $v;
}

sub _unsafe_get_by_regexp {
    my($unsafe, $self, $pattern) = @_;
    # Returns the field for unsafe_get_by_regexp and get_by_regexp.
    my($match);
    foreach my $k (@{$self->get_keys}) {
	next unless $k =~ /$pattern/;
	_die($self, $pattern, ': pattern matches more than one key',
	     ' (', $k, ' and ', $match, ')')
	    if defined($match)
#TODO: temporary to prevent problems with Model aliases on request
		&& $self->get($match) ne $self->get($k);
	$match = $k;
    }
    return !defined($match) ? $unsafe ? undef
	: _die($self, $pattern, ': pattern not found')
	: wantarray ? ($self->get($match), $match)
	: $self->get($match);
  }

# _writable($self) : $fields
sub _writable {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    _die($self, $_READ_ONLY_ERROR)
	if $fields->{$_READ_ONLY_ATTR};
    return $fields;
}

1;
