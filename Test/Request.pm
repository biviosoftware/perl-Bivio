# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Request;
use strict;
$Bivio::Test::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Request::VERSION;

=head1 NAME

Bivio::Test::Request - manages requests for tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Request;

=cut

=head1 EXTENDS

L<Bivio::Agent::Job::Request>

=cut

use Bivio::Agent::Job::Request;
@Bivio::Test::Request::ISA = ('Bivio::Agent::Job::Request');

=head1 DESCRIPTION

C<Bivio::Test::Request> manages requests for tests.  Simply importing creates a
new request running in general realm.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Type::DateTime;
use Bivio::Test::Bean;
use Socket ();

#=VARIABLES
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Test::Request

Returns an instance of self.

=cut

sub get_instance {
    my($proto) = @_;
    if ($_SELF) {
	Bivio::Die->die($_SELF, ': self not current request ',
	    $_SELF->get_current)
	    unless $_SELF->get_current == $_SELF;
    }
    else {
	$_SELF = $proto->new({
	    auth_id => undef,
	    auth_user_id => undef,
	    task_id => Bivio::Agent::TaskId->SHELL_UTIL,
	    timezone => Bivio::Type::DateTime->timezone,
	});
	$_SELF->set_realm(undef);
	$_SELF->set_user(undef);
    }
    return $_SELF;
}

=head1 METHODS

=cut

=for html <a name="setup_http"></a>

=head2 static setup_http(string cookie_class) : self

Sets up self to look like an http request.  You probably don't need
to pass I<cookie_class>.  See UserLoginForm.t and
PersistentCookie.t for examples.

If called statically, will call L<get_instance|"get_instance"> first.

Redirects are ignored.

=cut

sub setup_http {
    my($self, $cookie_class) = @_;
    $self = $self->get_instance unless ref($self);
    $self->ignore_redirects;
    # What's required by bOP infrastructure.
    Bivio::Type::UserAgent->BROWSER->execute($self, 1);
    my($r) = Bivio::Test::Bean->new;
    $self->put_durable(r => $r);
    my($c) = Bivio::Test::Bean->new;
    $r->connection($c);
    $c->remote_ip('127.0.0.1');
    $c->local_addr(
	Socket::pack_sockaddr_in(80, Socket::inet_aton($c->remote_ip)));
    $c->remote_addr($c->local_addr);
    $r->method('GET');
    $r->server(Bivio::Test::Bean->new);
    $r->uri('/');
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    delegates => {
		'Bivio::Agent::HTTP::Cookie' =>
		    $cookie_class || 'Bivio::Delegate::NoCookie',
	    },
	},
    });
    $self->put_durable(cookie => Bivio::Agent::HTTP::Cookie->new($self, $r));
    return $self;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
