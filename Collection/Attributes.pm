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
@Bivio::Collection::Attributes::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Collection::Attributes> provides a useful wrapper around a
hash of values.

It can be subclassed to allow arbitrary named attributes
without polluting a class's internal field name space.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;
# DON'T use Bivio::Die, because Die extends this module

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
    Bivio::IO::Alert->die($name, ': ancestral attribute not found');
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

=head2 delete(string key, ...)

Removes the named attribute(s) from the map.  They needn't exist.

=cut

sub delete {
    my($fields) = shift->{$_PACKAGE};
    die($_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    map {delete($fields->{$_})} @_;
    return;
}

=for html <a name="delete_all"></a>

=head2 delete_all()

Removes all the parameters.

=cut

sub delete_all {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    # This is probably the fastest way to remove all elements
    die($_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    $self->{$_PACKAGE} = {};
    return;
}

=for html <a name="dump"></a>

=head2 dump()

For debugging, dumps the current state to trace output. One level only.

=cut

sub dump {
    my($self) = @_;

    if ($_TRACE) {
	my($dump) = "\n";
	foreach my $k (@{$self->get_keys}) {
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
    shift;
    return shift if int(@_) <= 1;
    die('expecting an array context') unless wantarray;
    return @_;
}

=for html <a name="get"></a>

=head2 get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, C<die> is called.  Use
L<has_keys|"has_keys"> to test for existence.

=cut

sub get {
    my($fields) = shift(@_)->{$_PACKAGE};
    my(@res) = map {
	Bivio::IO::Alert->die($_, ": attribute doesn't exist")
		unless exists($fields->{$_});
	$fields->{$_};
    } @_;
    return @res if wantarray;
    die('get not called in array context') unless int(@res) == 1;
    return $res[0];
}

=for html <a name="get_by_regexp"></a>

=head2 get_by_regexp(string pattern) : string

Returns a single value by regular expression.  If not found, throws die.

=cut

sub get_by_regexp {
    my($self, $pattern) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($match);
    foreach my $k (keys(%$fields)) {
	next unless $k =~ /$pattern/;
	Bivio::IO::Alert->die($pattern, ': pattern matches more than one key',
		' (', $k, ' and ', $match, ')')
		    if $match;
	$match = $k;
    }
    Bivio::IO::Alert->die($pattern, ': pattern not found') unless $match;
    return $fields->{$match};
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
	    Bivio::IO::Alert->die($name, ": not an array index ", \@names)
			unless $name =~ /^\d+$/;
	    if ($name <= $#$v) {
		$v = $v->[$name];
		next;
	    }
	}
	else {
	    Bivio::IO::Alert->die("can't index \"", $v, '" at name"',
		    $name, '" ', \@names);
	}
	Bivio::IO::Alert->die($name, ": attribute doesn't exist ", \@names);
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

=head2 get_widget_value(string param1, ...) : string

Returns a value to the widget.  The return value is determined as follows:

=over 4

=over 4

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
    Bivio::IO::Alert->die('too few arguments passed to ', $self) unless @_;
    my($param1) = shift;
    my($value);

    # What value does $param1 identify?
    if (exists($fields->{$param1})) {
	# Plain old attribute, may be undef
	$value = $fields->{$param1};
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
	    Bivio::IO::Alert->die($param1, ': not found in source ', $self);
	}

	if (ref($param1) eq 'ARRAY') {
	    $value = $self->get_widget_value(@$param1);
	}
	elsif (ref($param1) eq 'CODE') {
	    $value = &$param1($self);
	}
	else {
	    Bivio::IO::Alert->die($param1,
		    ": not found and can't get_widget_value");
	}
    }

    # Have value figure out what to do with it
    unless (ref($value)) {
	# fall through, not a reference
    }
    elsif (!@_) {
	# No more params, further checking not required
	return $value;
    }
    elsif ($value =~ /=/) {
	# It's a blessed reference
	return $value->get_widget_value(@_)
    }
    else {
	# value is a hash or array ref
	my($param2) = shift;
	Bivio::IO::Alert->die($param1,
		': is a ref, but not passed second param')
		    unless defined($param2);
	$param2 = $self->get_widget_value(@$param2) if ref($param2) eq 'ARRAY';
	if (ref($value) eq 'HASH') {
	    # key must exist
	    Bivio::IO::Alert->die($param1, '->{', $param2, '}: does not exist')
			unless exists($value->{$param2});
	    $value = $value->{$param2};
	}
	elsif (ref($value) eq 'ARRAY') {
	    # index must exist (and be a number)
	    Bivio::IO::Alert->die($param1, '->[', $param2, ']: does not exist')
			unless $param2 <= $#{$value};
	    $value = $value->[$param2];
	}
	else {
	    Bivio::IO::Alert->die($param1, ': unsupported reference type: ',
		    ref($value));
	}
    }

    # Check for next param which must be able to get_widget_value.
    return $value unless @_;
    $param1 = shift(@_);
    return $param1->get_widget_value($value, @_)
	    if UNIVERSAL::can($param1, 'get_widget_value');
    Bivio::IO::Alert->die("$param1: can't get_widget_value (not a formatter)");
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
    die("protected method") unless caller(0)->isa(__PACKAGE__);
    return shift->{$_PACKAGE};
}


=for html <a name="internal_put"></a>

=head2 protected internal_put(hash_ref attrs)

Replaces all the attributes with the hash.  Only subclasses may call this
method (enforced).

Modifying the hash will modify the attributes.

=cut

sub internal_put {
    die("protected method") unless caller(0)->isa(__PACKAGE__);
    my($self, $fields) = @_;
    die($_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
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

=for html <a name="put"></a>

=head2 put(string key, string value, ...) : Bivio::Collection::Attributes

Adds or replaces the named value(s).

Returns I<self>.

=cut

sub put {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    die($_READ_ONLY_ERROR) if $fields->{$_READ_ONLY_ATTR};
    int(@_) % 2 == 0 || die("must be an even number of parameters");
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
    my($fields) = shift(@_)->{$_PACKAGE};
    my(@res) = map {
	exists($fields->{$_}) ? $fields->{$_} : undef;
    } @_;
    return @res if wantarray;
    die('unsafe_get not called in array context') unless int(@res) == 1;
    return $res[0];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
