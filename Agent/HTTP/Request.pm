# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
$Bivio::Agent::HTTP::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Request - An HTTP Request

=head1 EXTENDS

L<Bivio::Agent::Request>

=cut

use Bivio::Agent::Request;
@Bivio::Agent::HTTP::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Request> is a Bivio Request wrapper for an
Apache::Request. It gathers request information from the URI and posted
parameters. The general format is:

bivio.com/<target>/<operation>
&mf=<arg1>(<val1>),<arg2>(<val2>)...&op=<op>&...

  where <target> is a person or club
  <path> is value in the path map
  <arg1>(<val1>)... are model finder parameters
  <op> further qualifies <path>

The rest of the arguments are action parameters.  The path may be
partially complete as the path components have default values.

If the connection is using authentication and a
L<Bivio::Biz::PropertyModel::User|Bivio::Biz::PropertyModel::User> exists
for the login, then C<user> and C<password> entries will defined
in the Request's context (a L<Bivio::Biz::PropertyModel::User|Bivio::Biz::PropertyModel::User>
and string respectively).

=cut

#=IMPORTS
use Apache::Constants;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Reply;
use Bivio::Biz::PropertyModel::User;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Util;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Request

Creates a Request from an apache request.  The target and path are
separated.

=cut

sub new {
    my($proto, $r) = @_;
    my($start_time) = Bivio::Util::gettimeofday();
    # Sets Bivio::Agent::Request->get_current, so do the minimal thing
    my($self) = Bivio::Agent::Request::new($proto, {
	    start_time => $start_time,
	    reply => Bivio::Agent::HTTP::Reply->new($r),
    });
    # Always create query
    my($ret, $password) = $r->get_basic_auth_pw();
    my($auth_user) = ($ret == Apache::Constants::OK())
	    ? _auth_user($self, $r->connection->user, $password) : undef;
    my($auth_realm, $task_id)
	    = Bivio::Agent::HTTP::Location->parse($self, $r->uri);
    # NOTE: Syntax is weird to avoid passing $r->args in an array context
    # which avoids parsing $r->args.
    my($query) = (defined $r->args) ? +{$r->args} : undef;
    # Form may be undef
    my($form) = $r->method_number() eq Apache::Constants::M_POST()
	    ? {$r->content()} : undef;
    $self->put(
	    # FindParams are always unique.
	    auth_realm => $auth_realm,
	    auth_user => $auth_user,
	    form => $form,
	    query => {$r->args},
	    task_id => $task_id,
	   );
    return $self;
}

=head1 METHODS

=cut

=for html <a name="format_uri"></a>

=head2 format_uri(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Creates a URI relative to this host/port.
If I<query> is C<undef>, will not create a query string.
If I<auth_realm> is C<undef>, request's realm will be used.

=cut

sub format_uri {
    my($self, $task_id, $query, $auth_realm) = @_;
    # Note: Bivio::Agent::Mail::Request may call this.
    $task_id ||= $self->get('task_id');
    my($uri) = Bivio::Agent::HTTP::Location->format(
	    $task_id, $auth_realm || $self->get('auth_realm'));
    return $uri unless defined $query && %$query;
#TODO: Map query strings to brief names
    my(@s);
    while (my($k, $v) = each(%$query)) {
	push(@s, $k . '=' . Bivio::Util::escape_uri($v));
    }
    return $uri . '?' . join('&', @s);
}

#=PRIVATE METHODS

# _auth_user(string name, string password) : Bivio::Biz::PropertyModel::User
#
# Attempts to find a user with the specified login id.
sub _auth_user {
    my($self, $name, $password) = @_;
    return undef unless defined($name);
    my($user) = Bivio::Biz::PropertyModel::User->new($self);
    Bivio::Die->die(Bivio::DieCode::AUTH_REQUIRED(),
	    {request => $self, entity => $name})
	    unless $user->unauth_load(name => $name);
    Bivio::Die->die(Bivio::DieCode::AUTH_REQUIRED(),
	    {request => $self, message => 'password mismatch',
		entity => $name, auth_user => $user})
    	    unless $user->get('password') eq $password;
    return $user;
}

# _parse_uri(string uri) : (Bivio::Biz::Model, Bivio::Agent::Task)
#
# Takes a URI request and parses the realm and the task.
#
# input format: /<realm>[/<location>]
#
# Location may have one or more components separated by slashes.
# Realm and location are used to find the task.
#
sub _parse_uri {
    my($str) = @_;
    # trim leading and trailing '/'s
    $str =~ s,^/+|/+$,,g;
    my($target, @path) = split(m!/+!, $str);
    return ($target, \@path);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
