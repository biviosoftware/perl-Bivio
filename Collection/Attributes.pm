# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Collection::Attributes;
use strict;
$Bivio::Collection::Attributes::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Collection::Attributes - a collection of key/value pairs

=head1 SYNOPSIS

    use Bivio::Collection::Attributes;
    Bivio::Collection::Attributes->new($initial_map);

=cut

use Bivio::UNIVERSAL;
@Bivio::Collection::Attributes::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Collection::Attributes> provides a useful wrapper around a hash of values.

It can be subclassed to allow arbitrary named attributes
without polluting a class's internal field name space.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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
    $self->{$_PACKAGE} = $map || {};
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
    Carp::croak("$name: ancestral attribute not found");
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
    map {delete($fields->{$_})} @_;
    return;
}

=for html <a name="delete_all"></a>

=head2 delete_all()

Removes all the parameters.

=cut

sub delete_all {
    # This is probably the fastest way to remove all elements
    shift->{$_PACKAGE} = {};
    return;
}

=for html <a name="get"></a>

=head2 get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, C<die> is called.  Use
L<has_keys|"has_keys"> to test for existence.

=cut

sub get {
    my($fields) = shift(@_)->{$_PACKAGE};
    my(@res) = map {
	Carp::croak("$_: attribute doesn't exist")
		unless exists($fields->{$_});
	$fields->{$_};
    } @_;
    return @res if wantarray;
    die('get not called in array context') unless int(@res) == 1;
    return $res[0];
}

=for html <a name="get_keys"></a>

=head2 get_keys() : array_ref

Returns the list of keys.

=cut

sub get_keys {
    my(@names) = keys(%{shift->{$_PACKAGE}});
    return \@names;
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

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string param1, ...) : string

Returns a value to the widget.  The return value is determined as follows:

=over 4

=item 1.

I<param1> is a valid attribute,

=over 4

=item 1.1.

Attribute it is not a reference or there are no
more parameters, the value of the attribute will be returned unless there are
more parameters in which case the next parameter must be a blessed reference
which supports C<get_widget_value>.  The first argument will be the attribute
and the rest of the arguments will be passed.

=item 1.2.

Attribute whose value is a blessed reference, then the rest of the parameters
will be passed to C<get_widget_value> of the reference.

=item 1.3.

Attribute is hash or array reference, the second parameter will be used as a
key into the reference.  If there are more parameters, the third parameter must
be a blessed reference which supports C<get_widget_value>.  The first argument
will be the value from the hash, array, or indexed value
and the rest of the arguments will be passed.

=back

=item 2.1

If I<param1> begins with C<-E<gt>>, C<$self-E<gt>$param1(@_)> will be called.

=item 2.2.

If I<param1> I<can> C<get_widget_value>,
C<$param-E<gt>get_widget_value(@_)> will be called.

=item 2.3.

If I<param1> is an array reference, then
C<$self-E<gt>get_widget_value(@$param1)> will be called.

=item 3.

Otherwise, die will be called.

=back

=cut

sub get_widget_value {
    my($self) = shift;
    my($fields) = $self->{$_PACKAGE};
    my($param1) = shift;
    my($value);
    # No such key, try to call the method on $param1
    unless (exists($fields->{$param1})) {
	return $self->$param1(@_) if $param1 =~ s/^\-\>//;
	return $param1->get_widget_value(@_)
		if UNIVERSAL::can($param1, 'get_widget_value');
	Carp::croak("$param1: not found and can't get_widget_value")
		    unless ref($param1) eq 'ARRAY';
	$value = $self->get_widget_value(@$param1);
    }
    else {
	# scalar or undef attribute
	$value = $fields->{$param1};
    }
    unless (ref($value)) {
	# fall through
    }
    elsif (!@_) {
	# No more params, further checking not required
	return $value;
    }
    elsif ($value =~ /=/) {
	return $value->get_widget_value(@_)
    }
    else {
	# value is a ref
	my($param2) = shift;
	Carp::croak("$param1: is a ref, but not passed second param")
		    unless defined($param2);
	if (ref($value) eq 'HASH') {
	    # key must exist
	    Carp::croak("$param1\->{$param2}: does not exist")
			unless exists($value->{$param2});
	    $value = $value->{$param2};
	}
	elsif (ref($value) eq 'ARRAY') {
	    # index must exist (and be a number)
	    Carp::croak("$param1\->[$param2]: does not exist")
		unless $param2 <= $#{$value};
	    $value = $value->[$param2];
	}
	else {
	    Carp::croak("$param1: unsupported reference type: "
		    . ref($value));
	}
    }
    # Check for next param which must be able to get_widget_value.
    return $value unless @_;
    $param1 = shift(@_);
    return $param1->get_widget_value($value, @_)
	    if UNIVERSAL::can($param1, 'get_widget_value');
    Carp::croak("$param1: can't get_widget_value (not a formatter)");
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
    Carp::croak("protected method") unless caller(0)->isa(__PACKAGE__);
    return shift->{$_PACKAGE};
}


=for html <a name="internal_put"></a>

=head2 protected internal_put(hash_ref attrs)

Replaces all the attributes with the hash.  Only subclasses may call this
method (enforced).

Modifying the hash will modify the attributes.

=cut

sub internal_put {
    Carp::croak("protected method") unless caller(0)->isa(__PACKAGE__);
    my($self, $fields) = @_;
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

=head2 put(string key, string value, ...)

Adds or replaces the named value(s).

=cut

sub put {
    my($fields) = shift->{$_PACKAGE};
    int(@_) % 2 == 0 || Carp::croak("must be an even number of parameters");
    while (@_) {
	my($k, $v) = (shift(@_), shift(@_));
	$fields->{$k} = $v;
    }
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

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
