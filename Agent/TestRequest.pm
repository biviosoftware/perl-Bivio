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
components indepently from a web or mail server. TestRequest also
implements most of Bivio::Agent::Reply interface so it can act as
its own reply in calls to get('reply').

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Agent::HTTP::Location;

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

    # also handles its own replies
    $self->put('reply', $self);

    return $self;
}

=head1 METHODS

=cut

=for html <a name="flush"></a>

=head2 flush()

Reply method. NOP

=cut

sub flush {
    return;
}

=for html <a name="format_uri"></a>

=head2 abstract format_uri(Bivio::Agent::TaskId task_id) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, hash_ref query) : string

=head2 abstract format_uri(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Hacked implementation from HTTP::Request

=cut

sub format_uri {

    # HACK - use HTTP::Request implementation
    return Bivio::Agent::HTTP::Request::format_uri(@_);
}

=for html <a name="print"></a>

=head2 print(string str)

Reply method. Prints the specified value to STDOUT.

=cut

sub print {
    my($self, $str) = @_;
    print($str);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
