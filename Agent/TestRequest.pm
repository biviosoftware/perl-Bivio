# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::TestRequest;
use strict;
$Bivio::Agent::TestRequest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::TestRequest - a parameterized request for testing

=head1 SYNOPSIS

    use Bivio::Agent::TestRequest;
    Bivio::Agent::TestRequest->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::TestRequest::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::TestRequest> can be used for testing UI and Model
components indepently from a web or mail server.

=cut

#=IMPORTS
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 new(string target_name) : Bivio::Agent::TestRequest

=head2 new(string target_name, string controller_name) : Bivio::Agent::TestRequest

=head2 new(string target_name, string controller_name, User user) : Bivio::Agent::TestRequest

=head2 new(string target_name, string controller_name, User user, hash args) : Bivio::Agent::TestRequest

Creates a test request with the specified target, controller, and user.
An optional hash of initial args may also be specified

=cut

sub new {
    my($proto, $target, $controller, $user, $args) = @_;
    my($self) = &Bivio::Agent::Request::new($proto, $target, $controller,
	    $user, Bivio::Util::gettimeofday());
    $args ||= {};
    $self->{$_PACKAGE} = {
	args => $args
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_arg"></a>

=head2 get_arg(string name) : string

Returns the value of the named request argument.

=cut

sub get_arg {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{args}->{$name};
}

=for html <a name="log_error"></a>

=head2 log_error(string message)

Writes the message to STDERR.

=cut

sub log_error {
    my($self, $message) = @_;
    print(STDERR $message);
}

=for html <a name="print"></a>

=head2 print(string str)

Writes the value to STDOUT.

=cut

sub print {
    my($self, $str) = @_;
    print(STDOUT $str);
}

=for html <a name="put_arg"></a>

=head2 put_arg(string name, string value)

Adds or updates the argument to the specified value.

=cut

sub put_arg {
    my($self, $name, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{args}->{$name} = $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
