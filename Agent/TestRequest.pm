# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::TestRequest;
use strict;
$Bivio::Agent::TestRequest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::TestRequest - a parameterized request for testing

=head1 SYNOPSIS

    use Bivio::Agent::TestRequest;

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

=head2 new(hash attributes) : Bivio::Agent::TestRequest

Creates a test request with the specified attributes

=cut

sub new {
    my($proto, $attributes) = @_;
    $attributes->{start_time} = Bivio::Util::gettimeofday();
    my($self) = &Bivio::Agent::Request::new($proto, $attributes);

    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
