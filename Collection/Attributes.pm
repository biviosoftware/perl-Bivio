# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Collection::Attributes;
use strict;
$Bivio::Collection::Attributes::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Collection::Attributes::VERSION;

=head1 NAME

Bivio::Collection::Attributes - a collection of key/value pairs

=head1 SYNOPSIS

    use Bivio::Collection::Attributes;
    Bivio::Collection::Attributes->new($initial_map);

=cut

use Bivio::UNIVERSAL;
@Bivio::Collection::Attributes::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Collection::Attributes> provides a useful wrapper around a
hash of values.

It can be subclassed to allow arbitrary named attributes
without polluting a class's internal field name space.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_READ_ONLY_ERROR) = 'attempt to modify read-only instance';

# Not likely to be an attribute. NOT CHECKED.
my($_READ_ONLY_ATTR) = "$;";

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Collection::Attributes

Creates an empty instance.

=cut

=head2 static new(hash map) : Bivio::Collection::Attributes

Creates an instance with I<map>. The constructor doesn't copy
the map, so don't modify the hash after invoking this.

=cut


sub new {
    my($proto, $map) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $map = {} unless ref($map);
    $self->{$_PACKAGE} = $map;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="ancestral_get"></a>

=head2 ancestral_get(string name) : any

=head2 ancestral_get(string name, any default) : any

Returns the named attribute if found and defined.  If not found or not defined,
checks I<parent>'s attributes (recursively).  If none of the ancestors have the
attribute or isn't defined, dies if I<default> not supplied or returns
default.

=cut

sub ancestral_get {
    my($self, $name, $default) = @_;
    my($fields) = $self->{$_PACKAGE};
    while (1) {
	return $fields->{$name} if defined($fields->{$name});
	last unless defined($fields->{parent});
	$fields = $fields->{parent}->{$_PACKAGE};
    }
    return $default if int(@_) > 2;
    _die($self, $name, ': ancestral attribute not found');
    # DOES NOT RETURN
}

=for html <a name="ancestral_has_keys"></a>

=head2 ancestral_has_keys(string name, ...) : boolean

Returns true if all the named attributes exist (but may be C<undef>) in this
instance or its ancestors.

=cut

sub ancestral_has_keys {
    my($self, @names) = @_;
    _die($self, 'missing arguments') unless @names;
    my($fields) = $self->{$_PACKAGE};
    while (@names) {
	# Top of array checked first, since we're splicing as we go
	for (my($i) = $#names; $i >= 0; $i--) {
	    splice(@names, $i, 1) if exists($fields->{$names[$i]});
	}
	return @names ? 0 : 1 unless defined($fields->{parent});
	$fields = $fields->{parent}->{$_PACKAGE};
    }
    return 1;
}

=for html <a name="clone"></a>

=head2 clone() : Bivio::Collection::Attributes

Creates a duplicate copy of this instance.

I<Subclasses must override this method if their C<new> is different
from this class' C<new>.>

=cut

sub clone {
    my($self) = @_;
    return $self->new({%{$self->{$_PACKAGE}}});
}

=for html <a name="delete"></a>

=head2 delete(string key, ...) : self

Removes the named attribute(s) from the map.  They needn't exist.

=cut

sub delete {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    _die($self, $_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    map {delete($fields->{$_})} @_;
    return $self;
}

=for html <a name="delete_all"></a>

=head2 delete_all() : self

Removes all the parameters.

=cut

sub delete_all {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    # This is probably the fastest way to remove all elements
    _die($self, $_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    $self->{$_PACKAGE} = {};
    return $self;
}

=for html <a name="delete_all_by_regexp"></a>

=head2 delete_all_by_regexp(string pattern) : self

Deletes all keys matching I<pattern>.

=cut

sub delete_all_by_regexp {
    my($self, $pattern) = @_;
    my($fields) = $self->{$_PACKAGE};
    foreach my $k (keys(%$fields)) {
	next unless $k =~ /$pattern/;
	delete($fields->{$k});
    }
    return $self;
}

=for html <a name="dump"></a>

=head2 dump()

For debugging, dumps the current state to trace output. One level only.

=cut

sub dump {
    my($self) = @_;

    if ($_TRACE) {
	my($dump) = "\n";
	foreach my $k (sort(@{$self->get_keys})) {
	    my($value) = $self->get($k);
	    $dump .= "\t$k => ".(defined($value) ? $value : 'undef')."\n";
	}
	&_trace($dump);
    }
    return;
}

=for html <a name="echo"></a>

=head2 echo(any arg) : arg

=head2 echo(any arg, ...) : array

Returns its arguments.  Used for literal widget values.

=cut

sub echo {
    my($self) = shift;
    return shift if int(@_) <= 1;
    _die($self, 'expecting an array context') unless wantarray;
    return @_;
}

=for html <a name="get"></a>

=head2 get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, C<die> is called.  Use
L<has_keys|"has_keys"> to test for existence.

=cut

sub get {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    my(@res) = map {
	_die($self, $_, ": attribute doesn't exist")
		unless exists($fields->{$_});
	$fields->{$_};
    } @_;
    return @res if wantarray;
    _die($self, 'get not called in array context') unless int(@res) == 1;
    return $res[0];
}

=for html <a name="get_by_regexp"></a>

=head2 get_by_regexp(string pattern) : any

Returns a single value by regular expression.  If not found, throws die.

=cut

sub get_by_regexp {
    my($self, $pattern) = @_;
    my($match) = _unsafe_get_by_regexp(@_);
    _die($self, $pattern, ': pattern not found') unless defined($match);
    return $self->{$_PACKAGE}->{$match};
}

=for html <a name="get_if_exists_else_put"></a>

=head2 get_if_exists_else_put(string key, code_ref compute_value) : any

Returns value of I<key> if it exists.  Otherwise, calls I<compute_value>
and return the computed value.  Used to "cache" values which are
expensive to compute.

Returns the gotten or computed value.

=cut

sub get_if_exists_else_put {
    my($self, $key, $compute_value) = @_;
    return $self->get($key) if $self->has_keys($key);
    my($res) = &$compute_value();
    $self->put($key => $res);
    return $res;
}

=for html <a name="get_keys"></a>

=head2 get_keys() : array_ref

Returns the list of keys.

=cut

sub get_keys {
    my(@names) = keys(%{shift->{$_PACKAGE}});
    return \@names;
}

=for html <a name="get_nested"></a>

=head2 get_nested(string name, string subname, ...) : any

Looks up I<name> and indexes with I<subname>, if supplied.  Continues with
subnames.  Works both with hash_refs and array_refs.  There is type checking on
I<subname> if the value is an array_ref.

Similar to L<get_widget_value|"get_widget_value">, but not as complex.

Note that the value returned may be C<undef> if the nested lookup
exists, but is C<undef>.

=cut

sub get_nested {
    my($self, @names) = @_;
    my($v) = $self->{$_PACKAGE};
    foreach my $name (@names) {
	if (ref($v) eq 'HASH') {
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
	else {
	    _die($self, "can't index \"", $v, '" at name"',
		    $name, '" ', \@names);
	}
	_die($self, $name, ": attribute doesn't exist ", \@names);
    }
    return $v;
}

=for html <a name="get_or_default"></a>

=head2 get_or_default(string name, any default) : any

Returns the attribute if exists or I<default>.

=cut

sub get_or_default {
    my($self, $name, $default) = @_;
    my($fields) = $self->{$_PACKAGE};
    return exists($fields->{$name}) ? $fields->{$name} : $default;
}

=for html <a name="get_shallow_copy"></a>

=head2 get_shallow_copy() : hash_ref

Return a shallow copy of the attributes.

=cut

sub get_shallow_copy {
    return {%{shift->{$_PACKAGE}}};
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string param1, ...) : any

Returns a value to the widget.  The return value is determined as follows:

=over 4

=over 4

=item 1.0.

If <param1> is "!" (not), shifts arguments and calls recursively,
inverting the result (returning a valid Type::Boolean).

=item 1.1.

Attribute is not a reference or there are no more parameters.
The value of the attribute will be returned unless there are
more parameters in which case the next parameter must be a blessed reference
which supports C<get_widget_value>.  The first argument will be the attribute
and the rest of the arguments will be passed.

=item 1.2.

Attribute whose value is a blessed reference, then the rest of the parameters
will be passed to C<get_widget_value> of the reference.

=item 1.3.

Attribute is hash or array reference, the second parameter will be used as a
key into the reference.  If the second parameter is an array_ref,
its value will be interpreted by C<get_widget_value>.
If there are more parameters, the third parameter must
be a blessed reference which supports C<get_widget_value>.  The first argument
will be the value from the hash, array, or indexed value
and the rest of the arguments will be passed.

=back

=item 2.1.

If I<param1> begins with C<-E<gt>>, C<$self-E<gt>$param1(@_)> will be called.

=item 2.2.

If I<param1> I<can> C<get_widget_value>,
C<$param-E<gt>get_widget_value(@_)> will be called.

=item 2.3.

If I<param1> is an unblessed array reference, then
C<$self-E<gt>get_widget_value(@$param1)> will be called.

=item 2.4.

If I<param1> is an unblessed code reference, then
C<&$param1($self)> will be called.

=item 3.

Otherwise, die will be called.

=back

=cut

sub get_widget_value {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    _die($self, 'too few arguments passed to ', $self) unless @_;
    my($param1) = shift;
    my(@value);

    return $self->get_widget_value(@_) ? 0 : 1 if $param1 eq '!';

    # What value does $param1 identify?
    if (exists($fields->{$param1})) {
	# Plain old attribute, may be undef
	@value = ($fields->{$param1});
    }
    else {
	# No such key, try to call the method on $param1
	return $self->$param1(@_) if $param1 =~ s/^\-\>//;

	if (UNIVERSAL::can($param1, 'get_widget_value')) {
	    # Have to have params to call get_widget_value
	    return $param1->get_widget_value(@_) if @_;

#TODO: Document this very special case...
#	    # Return self if we're looking for self
#	    return $self if ref($self) eq $param1;

	    # Otherwise, couldn't find it.
	    _die($self, $param1, ': not found in source ', $self);
	}

	if (ref($param1) eq 'ARRAY') {
	    @value = $self->get_widget_value(@$param1);
	}
	elsif (ref($param1) eq 'CODE') {
	    @value = (&$param1($self));
	}
	else {
	    _die($self, $param1, ": not found and can't get_widget_value");
	}
    }

    # Have value figure out what to do with it
    unless (ref($value[0])) {
	# fall through, not a reference
    }
    elsif (!@_) {
	# No more params, further checking not required
	return wantarray ? @value : $value[0];
    }
    elsif ($value[0] =~ /=/) {
	# It's a blessed reference
	return $value[0]->get_widget_value(@_);
    }
    else {
	# value is a hash or array ref
	my($param2) = shift;
	die($self, $param1, ': is a ref, but not passed second param')
		    unless defined($param2);
	$param2 = $self->get_widget_value(@$param2)
		if ref($param2) eq 'ARRAY';
	if (ref($value[0]) eq 'HASH') {
	    # key must exist
	    _die($self, $param1, '->{', $param2, '}: does not exist')
			unless exists($value[0]->{$param2});
	    @value = ($value[0]->{$param2});
	}
	elsif (ref($value[0]) eq 'ARRAY') {
	    # index must exist (and be a number)
	    die($self, $param1, '->[', $param2, ']: does not exist')
			unless $param2 <= $#{$value[0]};
	    @value = ($value[0]->[$param2]);
	}
	else {
	    die($self, $param1, ': unsupported reference type: ',
		    ref($value[0]));
	}
    }

    # Check for next param which must be able to get_widget_value or
    # must be a widget value which returns something that can return
    # a widget value.
    return wantarray ? @value : $value[0] unless @_;
    $param1 = shift(@_);
    $param1 = $self->get_widget_value(@$param1) if ref($param1) eq 'ARRAY';
    return $param1->get_widget_value(@value, @_)
	    if UNIVERSAL::can($param1, 'get_widget_value');
    die($self, $param1,
	    ": can't get_widget_value (not a formatter)");
    # DOES NOT RETURN
}

=for html <a name="has_keys"></a>

=head2 has_keys(string key, string key2, ...) : boolean

Returns 1 if the named keys exist, otherwise 0.

=cut

sub has_keys {
    my($fields) = shift->{$_PACKAGE};
    map {exists($fields->{$_}) || return 0} @_;
    return 1;
}

=for html <a name="internal_get"></a>

=head2 protected internal_get() : hash_ref

Returns the attributes as a hash.  Only subclasses may call this
method (enforced).

Modifying the hash will modify the attributes.

=cut

sub internal_get {
    my($self) = @_;
    _die($self, "protected method") unless caller(0)->isa(__PACKAGE__);
    return $self->{$_PACKAGE};
}


=for html <a name="internal_put"></a>

=head2 protected internal_put(hash_ref attrs)

Replaces all the attributes with the hash.  Only subclasses may call this
method (enforced).

Modifying the hash will modify the attributes.

=cut

sub internal_put {
    my($self, $fields) = @_;
    _die($self, "protected method") unless caller(0)->isa(__PACKAGE__);
    _die($self, $_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    $self->{$_PACKAGE} = $fields;
    return;
}

=for html <a name="is_empty"></a>

=head2 is_empty() : boolean

Returns whether any attributes in the map.

=cut

sub is_empty {
    return !%{shift->{$_PACKAGE}};
}

=for html <a name="is_read_only"></a>

=head2 is_read_only() : boolean

Returns true if the view is READ_ONLY.

=cut

sub is_read_only {
    return shift->{$_PACKAGE}->{$_READ_ONLY_ATTR} ? 1 : 0;
}

=for html <a name="put"></a>

=head2 put(string key, string value, ...) : Bivio::Collection::Attributes

Adds or replaces the named value(s).

Returns I<self>.

=cut

sub put {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    _die($self, $_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    _die($self, "must be an even number of parameters")
	    unless int(@_) % 2 == 0;
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	$fields->{$k} = $v;
    }
    return $self;
}

=for html <a name="set_read_only"></a>

=head2 set_read_only()

Delete, put, etc. cannot be called.

=cut

sub set_read_only {
    my($fields) = shift->{$_PACKAGE};
    $fields->{$_READ_ONLY_ATTR} = 1;
    return;
}

=for html <a name="unsafe_get"></a>

=head2 unsafe_get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, C<undef> is returned
in its place. 

=cut

sub unsafe_get {
    my($self) = shift(@_);
    my($fields) = $self->{$_PACKAGE};
    my(@res) = map {
	exists($fields->{$_}) ? $fields->{$_} : undef;
    } @_;
    return @res if wantarray;
    _die($self, 'unsafe_get not called in array context')
	    unless int(@res) == 1;
    return $res[0];
}

=for html <a name="unsafe_get_by_regexp"></a>

=head2 unsafe_get_by_regexp(string pattern) : any

Returns a single value by regular expression.  If not found, returns
undef.

If multiple found, throws exception.

=cut

sub unsafe_get_by_regexp {
    my($self, $pattern) = @_;
    my($match) = _unsafe_get_by_regexp(@_);
    return defined($match) ? $self->{$_PACKAGE}->{$match} : undef;
}

#=PRIVATE METHODS

# _die(self, any msg, ...)
#
# Terminates with nice message
#
sub _die {
    my($self, @msg) = @_;
    my($sub) = (caller(1))[3];
    $sub =~ s/.*://;
    my($die) = UNIVERSAL::isa('Bivio::Die', 'Bivio::UNIVERSAL')
	    ? 'Bivio::Die' : 'Bivio::IO::Alert';
    $die->die($self, '->', $sub, ': ', @msg);
    # DOES NOT RETURN
}

# _unsafe_get_by_regexp(Bivio::Collection::Attributes self, string pattern) : string
#
# Returns the field for unsafe_get_by_regexp and get_by_regexp.
#
sub _unsafe_get_by_regexp {
    my($self, $pattern) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($match);
    foreach my $k (keys(%$fields)) {
	next unless $k =~ /$pattern/;
	_die($self, $pattern, ': pattern matches more than one key',
		' (', $k, ' and ', $match, ')')
		    if defined($match)
#TODO: temporary to prevent problems with Model aliases on request
			    && $self->get($match) ne $self->get($k);
	$match = $k;
    }
    return $match;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
