# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent::Text;
use strict;
use Bivio::Base 'UI.FacadeComponent';
use Bivio::IO::Trace;

# C<Bivio::UI::Text> maps internal names to UI strings.  In the
# simple case, names map to values, e.g.
#
#      group(my_name => 'my name for the UI');
#
# You can have multiple aliases for the same string, e.g.
#
#      group(['my_name', 'any_name']  => 'my name for the UI');
#
# Sometimes it is convenient to qualify a string's use, e.g. only use
# it within the context of one particular form.  For example,
#
#      group(LoginForm => [
#          name => 'User ID or Email',
#      ]);
#
# You might add in other names in this group, e.g.
#
#      group(LoginForm => [
#          name => 'User ID or Email',
#          password => 'Password',
#      ]);
#
# You may nest tag parts as deeply as you like:
#
#      group(LoginForm => [
#          RealmOwner => [
#             name => 'User ID or Email',
#          ],
#      ]);
#
# When looking up names, the tag parts are applied if they are found.  If there
# is no tag part, it is dropped and the next tag part is used.  Please see
# L<get_value|"get_value"> for more details.
#
# The empty tag is allowed at a nested level only.  It must point to a terminal
# value (not another level of nesting).  It is used when a determinant name
# is also an intermediate name, e.g.
#
#      group(phone => [
# 	[phone, ''] => 'Phone',
#      ]);
#
# The tags C<phone> and C<phone.phone> will point to C<Phone>.
#
# Tags are grouped to share values (as with other FacadeComponents).  A composite
# tag is formed out of the tag parts by L<group|"group"> or L<regroup|"regroup">.
# A single call to one of these methods may result in multiple groups being
# formed, e.g.
#
#      group(LoginForm => [
#          RealmOwner => [
#             name => 'User ID or Email',
#             password => 'Password',
#          ],
#      ]);
#
# Will form two groups, each with one member.  The above is equivalent to:
#
#      group('LoginForm.RealmOwner.name' => 'User ID or Email');
#      group('LoginForm.RealmOwner.password' => 'Password');
#
# The interface intends to be intuitive, but intuition is not always obvious.
# When in doubt, read the code or experiment.
#
# You can permute as much as you like, but this may result in combinatorial
# explosion, i.e. don't do:
#
#      group(['a'..'z'] => [
#           ['a'..'z'] => [
#               ['a'..'z'] => [
#                   'some value',
#               ]]]);
#
# This will result in 26^3 names for 'some value'.  It's unlikely that you
# want this.
#
#
#
# home_page_uri : string
#
# Where to redirect to when the user browses '/', i.e. the document
# root without any path_info.  Used by
# L<Bivio::Biz::Action::ClientRedirect::execute_if_home_page|Bivio::Biz::Action::ClientRedirect/"execute_if_home_page">

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_R) = b_use('Agent.Request');

sub SEPARATOR {
    # Returns tag part separator ('.') which allows parts to be joined into
    # a single string called a I<composite tag part>, e.g. C<RealmOwner.name> is
    # a composite tag part comprising the two tag parts C<RealmOwner> and
    # C<name>.
    return '.';
}

sub UNDEF_VALUE {
    # Returns the string "TEXT-ERR", the string returned if a value
    # cannot be found.
    return 'TEXT-ERR';
}

sub assert_name {
    my($self, $name) = @_;
    # We allow 'x.y' names.
    $self->die($name, 'invalid name syntax')
	unless $name =~ /^\w+(\Q@{[$self->SEPARATOR]}\E\w+)*$/;
    return;
}

sub facade_text_for_object {
    my($proto, $object, $req) = @_;
    my($self) = $proto->internal_get_self($req);
#TODO: Encapsulate reverse map in ClassLoader
    my($n) = [split(/:+/, $object->package_name)];
    b_die($object->package_name, ': must begin with project part, e.g. Bivio::')
	if @$n <= 1;
    $n->[0] = 'Bivio';
    my($v) = $self->unsafe_get_value(
	splice(@$n, -2),
	$object->as_facade_text_tag,
    );
    return defined($v) ? $v : $object->as_facade_text_default($req);
}

sub format_css {
    my($v) = shift->get_value(@_);
    return ''
	unless length($v);
    $v =~ s/(?=["\\])/\\/sg;
    $v =~ s/\n/\\A/sg;
    return qq{"$v"};
}

sub get_value {
    my($proto, @tag_part) = @_;
    # The simple case is a single I<tag_part> with no L<SEPARATOR|"SEPARATOR">s
    # passed to an
    # instance of this FacadeComponent, i.e.  I<facade_or_req> is C<undef>.  The
    # I<tag_part> identifies a piece of text to be returned.
    #
    # If there is more than one I<tag_part> or I<composite tag parts>, e.g.
    #
    #    get_value('LoginForm', 'RealmOwner.password');
    #
    # The first argument is a simple tag part.  The second argument is a
    # the composite tag parts comprised of the two simple tag parts:
    # C<RealmOwner> and C<password>.  This is identical to the call:
    #
    #    get_value('LoginForm', 'RealmOwner', 'password');
    #
    # If the C<LoginForm> tag part exists as a top-level tag part (FacadeComponent
    # group), it must contain either C<RealmOwner>.  If C<RealmOwner> exists, it must
    # contain C<password>.
    #
    # If C<LoginForm> top-level tag part doesn't exist, C<RealmOwner> defines the
    # top-level tag part and C<password> must exist within C<RealmOwner>.
    #
    # If neither C<LoginForm> nor C<RealmOwner> exist, the C<password> group must
    # exist.
    #
    # Note that C<password> must exist in all cases.  The searching algorithm
    # is loose enough to allow for flexibility at all levels, but the final
    # I<tag_part> is the determinant.  It must exist.
    #
    # If I<facade_or_req> is passed, the FacadeComponent from the facade or
    # from the request's facade will be retrieved and used to get the value.
    #
    # I<tag_part>'s are case insensitive.
    #
    # If I<tag_part> does not identify a group (top-level tag part), indicates an
    # error (which may cause a die, see FacadeComponent) and returns
    # L<UNDEF_CONFIG|"UNDEF_CONFIG">
    my($self) = $proto->internal_get_self(
	ref($tag_part[$#tag_part]) ? pop(@tag_part) : undef);
    my($v, $tag) = $self->unsafe_get_value(@tag_part);
    # $v is always defined for tags which are found except in subclasses.
    return defined($tag) ? $v
	: $self->get_error($self->join_tag(@tag_part))->{value};
}

sub get_widget_value {
    my($self, @tag) = @_;
    # I<tag_part>s are passed to L<get_value|"get_value">.
    #
    # If I<method_call> is passed (-E<gt>method), super will be called which
    # will call the method appropriately.
    # SUPER has code to handle ->, which we don't allow in names
    return $tag[0] =~ /^->/ ? $self->SUPER::get_widget_value(@tag)
	: $self->get_value(@tag);
}

sub group {
    my($self, $name, $value) = @_;
    # Creates a new group.  The I<name>s must be unique.  The I<value>
    # is defined by the subclass.  If it is a ref, ownership of I<value> is
    # taken by this module.
    #
    # This method overrides normal FacadeComponent behavior.  See DESCRIPTION
    # for more details.
    foreach my $group (@{_group($self, $name, $value)}) {
	$self->SUPER::group(@$group);
    }
    return;
}

sub internal_assert_value {
    my($self, $value, $name) = @_;
    $self->die($value, $name, ': value must be a defined string')
	unless defined($value) && !ref($value);
    return $value
}

sub internal_initialize_value {
    my($self, $value) = @_;
    # Initializes a value.  The group management has already taken place
    # (see L<group|"group">.
    my($v) = $value->{config};
    if (ref($v)) {
	# This shouldn't happen, but good to check
	$self->initialization_error(
	    $value, 'expecting a string, not a reference');
	$v = undef;
    }
    # Undefined is error
    $value->{value} = defined($v) ? $v : $self->UNDEF_VALUE();
    return;
}

sub join_tag {
    my($proto, @tag) = @_;
    my($r) = $_R->get_current;
    if ($r and $r = $r->unsafe_get('auth_realm') and $r->has_owner) {
	(my $n = $r->get('owner_name')) =~ s/\W/_/g;
	unshift(@tag, 'realm_owner_' . $n);
    }
    return int(@tag) == 1 && $tag[0] =~ /^[a-z0-9_\.]+$/ ? $tag[0]
	: join($proto->SEPARATOR, map((length($_) ? $_ : ()), @tag));
}

sub split_tag {
    my($self, $tag) = @_;
    return [split(/\./, $tag)];
}

sub unsafe_get_value {
    my($self) = shift;
    # You probably want to call L<get_value|"get_value">.
    #
    # Returns C<undef> if it cannot get the value, and doesn't output an error.
    my($tag) = $self->join_tag(@_);
    # We search a diagonal matrix.  We iterate over the $tag until we
    # find a match.  Chops off front component each time, if not found.
    my($v);
    my($sep) = $self->SEPARATOR;
    while ($tag) {
	$v = $self->internal_unsafe_lc_get_value($tag);
	return wantarray ? ($v->{value}, $tag) : $v->{value}
	    if $v;
	# Chop off top level.  If unable to do replacement, the tag
	# is bad so can't be found.
	last
	    unless $tag =~ s/^.+?\Q$sep//;
    }
    return wantarray ? (undef, undef) : undef;
}

sub unsafe_get_widget_value_by_name {
    my($self, $tag) = @_;
    # Returns the text value identified by the fully-qualified I<tag> if defined.
    my($v) = $self->internal_unsafe_lc_get_value($tag);
    return $v ? ($v->{value}, 1) : (undef, 0);
}

sub _group {
    my($self, $name, $value, $parent_names, $groups) = @_;
    # Returns the permutations found in name and value.  $parent_names is
    # used to pass info to recursive calls.  It contains the list of
    # prefixes to prepended to $name.
    $name = [$name]
	unless ref($name);
    $name = _group_assert_name($self, $name);
    $groups ||= [];
    $name = [
	map({
	    my($p) = $_;
	    map(length($_) ? $p . $self->SEPARATOR . $_ : $p, @$name);
	} @$parent_names),
    ] if $parent_names;
    if (ref($value) eq 'ARRAY' && @$value > 1) {
	$self->map_by_two(sub {
	    my($n, $v) = @_;
	    _group($self, $n, $v, $name, $groups);
	    return;
	}, $value);
    }
    else {
	push(@$groups, [$name, $value]);
    }
    return $groups;
}

sub _group_assert_name {
    my($self, $v) = @_;
    $self->die($v, ' name array_ref must not be empty')
	unless ref($v) ne 'ARRAY' || int(@$v) > 0;
    $self->die($v, 'name must be an array_ref or string')
	unless defined($v) && (ref($v) eq 'ARRAY' || !ref($v));
    foreach my $n (@$v) {
	$self->die($v, 'name array_ref must consist of strings')
	    unless defined($n) && !ref($n);
    }
    return $v;
}

1;
