# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Text;
use strict;
$Bivio::UI::Text::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::VERSION;

=head1 NAME

Bivio::UI::Text - tagged text of a facade

=head1 SYNOPSIS

    use Bivio::UI::Text;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Text::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Text> maps internal names to UI strings.  In the
simple case, names map to values, e.g.

     group(my_name => 'my name for the UI');

You can have multiple aliases for the same string, e.g.

     group(['my_name', 'any_name']  => 'my name for the UI');

Sometimes it is convenient to qualify a string's use, e.g. only use
it within the context of one particular form.  For example,

     group(LoginForm => [
         name => 'User ID or Email',
     ]);

You might add in other names in this group, e.g.

     group(LoginForm => [
         name => 'User ID or Email',
         password => 'Password',
     ]);

You may nest tag parts as deeply as you like:

     group(LoginForm => [
         RealmOwner => [
            name => 'User ID or Email',
         ],
     ]);

When looking up names, the tag parts are applied if they are found.  If there
is no tag part, it is dropped and the next tag part is used.  Please see
L<get_value|"get_value"> for more details.

The empty tag is allowed at a nested level only.  It must point to a terminal
value (not another level of nesting).  It is used when a determinant name
is also an intermediate name, e.g.

     group(phone => [
	[phone, ''] => 'Phone',
     ]);

The tags C<phone> and C<phone.phone> will point to C<Phone>.

Tags are grouped to share values (as with other FacadeComponents).  A composite
tag is formed out of the tag parts by L<group|"group"> or L<regroup|"regroup">.
A single call to one of these methods may result in multiple groups being
formed, e.g.

     group(LoginForm => [
         RealmOwner => [
            name => 'User ID or Email',
            password => 'Password',
         ],
     ]);

Will form two groups, each with one member.  The above is equivalent to:

     group('LoginForm.RealmOwner.name' => 'User ID or Email');
     group('LoginForm.RealmOwner.password' => 'Password');

The interface intends to be intuitive, but intuition is not always obvious.
When in doubt, read the code or experiment.

You can permute as much as you like, but this may result in combinatorial
explosion, i.e. don't do:

     group(['a'..'z'] => [
          ['a'..'z'] => [
              ['a'..'z'] => [
                  'some value',
              ]]]);

This will result in 26^3 names for 'some value'.  It's unlikely that you
want this.

=cut

=head1 CONSTANTS

=cut

=for html <a name="SEPARATOR"></a>

=head2 SEPARATOR : string

Returns tag part separator ('.') which allows parts to be joined into
a single string called a I<composite tag part>, e.g. C<RealmOwner.name> is
a composite tag part comprising the two tag parts C<RealmOwner> and
C<name>.

=cut

sub SEPARATOR {
    return '.';
}

=for html <a name="UNDEF_VALUE"></a>

=head2 UNDEF_VALUE : string

Returns the string "TEXT-ERR", the string returned if a value
cannot be found.

=cut

sub UNDEF_VALUE {
    return 'TEXT-ERR';
}

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_SEP) = SEPARATOR();
my($_SEP_PAT) = SEPARATOR();
$_SEP_PAT =~ s/(\W)/\\$1/g;

=head1 METHODS

=cut

=for html <a name="assert_name"></a>

=head2 assert_name(string name)

We allow 'x.y' names.

=cut

sub assert_name {
    my($self, $name) = @_;
    $self->die($name, 'invalid name syntax')
	    unless $name =~ /^\w+($_SEP_PAT\w+)*$/;
    return;
}

=for html <a name="get_value"></a>

=head2 get_value(string tag_part, ..., Bivio::Collection::Attributes facade_or_req) : string

The simple case is a single I<tag_part> with no L<SEPARATOR|"SEPARATOR">s
passed to an
instance of this FacadeComponent, i.e.  I<facade_or_req> is C<undef>.  The
I<tag_part> identifies a piece of text to be returned.

If there is more than one I<tag_part> or I<composite tag parts>, e.g.

   get_value('LoginForm', 'RealmOwner.password');

The first argument is a simple tag part.  The second argument is a
the composite tag parts comprised of the two simple tag parts:
C<RealmOwner> and C<password>.  This is identical to the call:

   get_value('LoginForm', 'RealmOwner', 'password');

If the C<LoginForm> tag part exists as a top-level tag part (FacadeComponent
group), it must contain either C<RealmOwner>.  If C<RealmOwner> exists, it must
contain C<password>.

If C<LoginForm> top-level tag part doesn't exist, C<RealmOwner> defines the
top-level tag part and C<password> must exist within C<RealmOwner>.

If neither C<LoginForm> nor C<RealmOwner> exist, the C<password> group must
exist.

Note that C<password> must exist in all cases.  The searching algorithm
is loose enough to allow for flexibility at all levels, but the final
I<tag_part> is the determinant.  It must exist.

If I<facade_or_req> is passed, the FacadeComponent from the facade or
from the request's facade will be retrieved and used to get the value.

I<tag_part>'s are case insensitive.

If I<tag_part> does not identify a group (top-level tag part), indicates an
error (which may cause a die, see FacadeComponent) and returns
L<UNDEF_CONFIG|"UNDEF_CONFIG">

=cut

sub get_value {
    my($proto, @tag_part) = @_;
    my($req_or_facade) = ref(@tag_part->[$#tag_part]) ? pop(@tag_part) : undef;
    my($self) = $proto->internal_get_self($req_or_facade);
    my($tag) = _join_tag(\@tag_part);
    # We search a diagonal matrix.  We iterate over the $tag until we
    # find a match.  Chops off front component each time, if not found.
    my($v);
    while ($tag) {
	$v = $self->internal_unsafe_lc_get_value($tag);
	return $v->{value} if $v;
	# Chop off top level.  If unable to do replacement, the tag
	# is bad so can't be found.
	last unless $tag =~ s/^\w+($_SEP_PAT)?//g;
    }
    return $self->get_error(\@tag_part)->{value};
}

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string tag_part, ...) : string

=head2 get_widget_value(string method_call, string tag_part, ...) : string

I<tag_part>s are passed to L<get_value|"get_value">.

If I<method_call> is passed (-E<gt>method), super will be called which
will call the method appropriately.

=cut

sub get_widget_value {
    my($self, @tag) = @_;
    # SUPER has code to handle this
    return $self->SUPER::get_widget_value(@tag) if $tag[0] =~ /^->/;
    # defaults to get_value
    return $self->get_value(@tag);
}

=for html <a name="group"></a>

=head2 group(string name, any value)

=head2 group(array_ref names, any value)

Creates a new group.  The I<name>s must be unique.  The I<value>
is defined by the subclass.  If it is a ref, ownership of I<value> is
taken by this module.

This method overrides normal FacadeComponent behavior.  See DESCRIPTION
for more details.

=cut

sub group {
    my($self, $name, $value) = @_;
    foreach my $group (@{_group($self, $name, $value)}) {
	$self->SUPER::group(@$group);
    }
    return;
}

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto);
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Initializes a value.  The group management has already taken place
(see L<group|"group">.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    if (ref($v)) {
	# This shouldn't happen, but good to check
	$self->initialization_error(
		$value, 'expecting a string, not a reference');
	$v = undef;
    }
    # Undefined is error
    $value->{value} = defined($v) ? $v : UNDEF_VALUE();
    return;
}

=for html <a name="join_tag"></a>

=head2 static join_tag(string tag_part, ...) : string

Returns I<tag_part>s combined as a whole.

=cut

sub join_tag {
    my($proto, @tag) = @_;
    return _join_tag(\@tag);
}

=for html <a name="regroup"></a>

=head2 regroup(string name, any new_value)

=head2 regroup(array_ref names, any new_value)

Takes existing I<names> and re-associates with I<new_value>.
All names must exist.

=cut

sub regroup {
    my($self, $name, $value) = @_;
    foreach my $group (@{_group($self, $name, $value)}) {
	$self->SUPER::regroup(@$group);
    }
    return;
}

#=PRIVATE METHODS

# _assert_group_arg(self, string which, any v)
#
# Checks to make sure $v is an array_ref or string.
#
sub _assert_group_arg {
    my($self, $which, $v) = @_;
    $self->die($v, $which, ' must be an array_ref or string')
	    unless defined($v) && (ref($v) eq 'ARRAY' || !ref($v));
    $self->die($v, $which, ' array_ref must not be empty')
	    unless ref($v) ne 'ARRAY' || int(@$v) > 0;
    if ($which eq 'name') {
	foreach my $n (@$v) {
	    $self->die($v, 'name array_ref must consist of strings')
		    unless defined($n) && !ref($n);
	}
    }
    elsif ($which eq 'value') {
	$self->die($v, 'value must contain even number of elements')
		if ref($v) && int(@$v) % 2 != 0;
    }
    return;
}

# _init_value(self, hash_ref decl, any values) : hash_ref
#
# Returns $values a values value.
#
sub _check_value {
    my($self, $decl, $values) = @_;
    unless (ref($values)) {
	$self->die($decl, 'undefined value') unless defined($values);
	return $values;
    }
    if (ref($values) eq 'ARRAY') {
	$self->($decl, 'odd number of elements in value: ', $values)
		if int(@$values) % 2 == 0;
	return $values;
    }
    return [%$values] if ref($values) eq 'HASH';
    $self->die($values, 'invalid value: ', $values);
    # DOES NOT RETURN
}

# _group(self, any name, any value, array_ref parent_names) : array_ref
#
# Returns the permutations found in name and value.  $parent_names is
# used to pass info to recursive calls.  It contains the list of
# prefixes to prepended to $name.
#
sub _group {
    my($self, $name, $value, $parent_names, $groups) = @_;
    _assert_group_arg($self, 'value', $value);
    $name = [$name] unless ref($name);
    _assert_group_arg($self, 'name', $name);
    $groups ||= [];

    # Permute parent names over our names
    $name = [map {
	my($p) = $_;
	map {
	    # We don't append our name if it is "blank"
	    length($_) ? $p.$_SEP.$_ : $p;
	} @$name;
    } @$parent_names]
	    if $parent_names;

    # Create tuples
    if (ref($value)) {
	# Recurse with our names as parent_names
	my(@value) = @$value;
	while (@value) {
	    my($n, $v) = splice(@value, 0, 2);
	    _group($self, $n, $v, $name, $groups);
	}
    }
    else {
	# Terminal condition is when we hit a scalar
	push(@$groups, [$name, $value]);
    }
    return $groups;
}

# _init_value(self, hash_ref decl, array_ref values) : hash_ref
#
# $values is a complex value.  Turn into a hash_ref.  $decl is value
# passed into internal_initialize_value.
#
# Unrolls the declaration.
#
sub _init_value {
    my($self, $decl, $values) = @_;
    $values = _check_value($self, $decl, $values);
    return $values unless ref($values);

    my(%res);
    while (@$values) {
	my($name, $value) = splice(@$values, 0, 2);
	my($v) = _init_value($self, $decl, $value);
	foreach my $n (ref($name) ? @$name : $name) {
	    $self->die($value, 'duplicate tag: ', $n) if $res{$n};
	    if (length($n)) {
		$self->assert_name($n);
	    }
	    elsif (ref($v)) {
		$self->die($value, 'empty tag must point to string, not ref');
	    }
	    $res{$n} = $v;
	}
    }
    return \%res;
}

# _join_tag(array_ref tag) : arrary
#
# Implements join_tag without assertions.  Empty elements are tossed.
#
sub _join_tag {
    my($tag) = @_;
    # Optimization
    return $tag->[0] if int(@$tag) == 1 && $tag->[0] =~ /^[a-z0-9_.]+$/;

    return join($_SEP, map {length($_) ? lc($_) : ()} @$tag);
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
