# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::User;

use strict;

use Bivio::Data;

$Bivio::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($self) = &Bivio::Data::lookup($_HOME . $name, $proto, $br);
    defined($self) || $br->auth_failure($name, ': no such user');
    my($salt) = substr($self->{passwd}, 0, 2);
    crypt($sent_pw, $salt) eq $self->{passwd} ||
	$br->auth_failure($name, ': bad password');
    $br->set_user($self);
    return $self;
}

sub init ($$$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
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
