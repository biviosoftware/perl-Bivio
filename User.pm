# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::User;

use strict;

use Bivio::Data;

$Bivio::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

BEGIN {
    use Bivio::Util;
    &Bivio::Util::compile_attribute_accessors(
	[qw(name passwd first_name middle_name last_name street apt
	 city state zip home_phone email home_page biography)],
	'no_set');
}

my $_HOME = 'users/';

# authenticate $class $br -> $user
#   Extracts the user/passwd from the incoming record and searches the
#   database for the user.
sub authenticate ($$)
{
    my($proto, $br) = @_;
    my($ret, $sent_pw) = $br->r->get_basic_auth_pw();
    $ret != 0 && $br->auth_failure('need user/passwd');
    my($name) = $br->r->connection->user;
    my($self) = &lookup($proto, $name, $br);
    defined($self) || $br->auth_failure($name, ': no such user');
    my($salt) = substr($self->passwd, 0, 2);
    crypt($sent_pw, $salt) eq $self->passwd ||
	$br->auth_failure($name, ': bad password');
    $br->set_user($self);
    return $self;
}

sub init ($$$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
}

# lookup $proto $name $br -> $user
#
#   Looks up the user and returns it.  If the user isn't found, undef is
#   returned.  Should not be used to authenticate users.  See &authenticate.
sub lookup ($$$) {
    my($proto, $name, $br) = @_;
    my($self) = &Bivio::Data::lookup($_HOME . $name, $proto, $br);
}

# lookup_sorted_by_last_first_name $proto \@names $br -> \@users
#
#   Looks up \@names and sorts by last first name.  If the user isn't
#   found, the name will be used and returned in the list, i.e.
#   the test for success of a particular element is ref($users->[$n]).
sub lookup_sorted_by_last_first_name ($$$) {
    my($proto, $names, $br) = @_;
    my(@users) = ();
    my($n);
    foreach $n (@$names) {
	my($u) = $proto->lookup($n, $br);
	my($fn) = $n;
	if (defined($u)) {
	    defined($u->last_name) && ($fn = $u->last_name);
	    defined($u->first_name) && ($fn .= ' ' . $u->first_name);
	}
	push(@users, [$fn, $u]);
    }
    # This is a load of perl, huh? Looks more like Lisp!
    # Sort the list of users found above case-insensitively.
    # Then create an array of the sorted result by selecting either
    # the $u reference ($_->[1]) if defined or the sorting name $_->[0]
    return [map {defined($_->[1]) ? $_->[1] : $_->[0]}
	     (sort {lc($a->[0]) cmp lc($b->[0])} @users)];
}

# Name to be used for displaying the user
sub full_name ($) {
    my($self) = shift;
    my($n) = '';
    defined($self->first_name) && ($n .= $self->first_name);
    defined($self->last_name) && ($n .= ' ' . $self->last_name);
    $n =~ s/^ //;
    return $n;
}

sub full_address ($) {
    my($self) = shift;
    my($n) = '';
    my($res) = [];
    defined($self->street) && ($n .= $self->street);
    defined($self->apt) && ($n .= ', ' . $self->apt);
    $n =~ s/^, //;
    push(@$res, $n);
    $n = '';
    defined($self->city) && ($n .= $self->city);
    defined($self->state) && ($n .= ', ' . $self->state);
    $n =~ s/^, //;
    defined($self->zip) && ($n .= ' ' . $self->zip);
    $n =~ s/^ //;
    push(@$res, $n);
    return $res;
}

1;
__END__

=head1 NAME

Bivio::User - Configure a user for an incoming request.

=head1 SYNOPSIS

  use Bivio::User;

=head1 DESCRIPTION

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

Bivio::Club

=cut
