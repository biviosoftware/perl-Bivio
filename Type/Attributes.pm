# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Attributes;
use strict;
$Bivio::Type::Attributes::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Attributes - a collection of key/value pairs

=head1 SYNOPSIS

    use Bivio::Type::Attributes;
    Bivio::Type::Attributes->new($initial_map);

=cut

use Bivio::UNIVERSAL;
@Bivio::Type::Attributes::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Type::Attributes> provides a useful wrapper around a hash of values.

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

=head2 static new() : Bivio::Type::Attributes

Creates an empty instance.

=cut

=head2 static new(hash map) : Bivio::Type::Attributes

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

=for html <a name="clone"></a>

=head2 clone() : Bivio::Type::Attributes

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

=for html <a name="has_keys"></a>

=head2 has_keys(string key, string key2, ...) : boolean

Returns 1 if the named keys exist, otherwise 0.

=cut

sub has_keys {
    my($fields) = shift->{$_PACKAGE};
    map {exists($fields->{$_}) || return 0} @_;
    return 1;
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
