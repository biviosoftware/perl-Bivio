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
L<Bivio::Biz::Model::User|Bivio::Biz::Model::User> exists
for the login, then C<user> and C<password> entries will defined
in the Request's context (a L<Bivio::Biz::Model::User|Bivio::Biz::Model::User>
and string respectively).

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Apache::Constants;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Reply;
use Bivio::Biz::Model::User;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

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
    my($uri) = $r->uri;
    my($auth_realm, $task_id)
	    = Bivio::Agent::HTTP::Location->parse($self, $uri);
#TODO: Make secure.  Need to watch for large queries and forms here.
    # NOTE: Syntax is weird to avoid passing $r->args in an array context
    # which avoids parsing $r->args.
    my $query_string = $r->args;
#TODO: Apache bug: ?bla&foo=1 will generate "odd number elements in hash"
#      warning.
    my($query) = defined($query_string) ? {$r->args} : undef;
    my($form) = $r->method_number() eq Apache::Constants::M_POST()
	    ? {$r->content()} : undef;
    _trace($r->method, ': form= ', $form, ' query= ', $query) if $_TRACE;

    # AUTH: Make sure the auth_id is NEVER set by the user.
    #       We are making a presumption about how the models work.
    #       However, it is reasonable to assume that there should never
    #       be a query or form field called "auth_id".
    delete($query->{auth_id}) if $query;
    delete($form->{auth_id}) if $form;

    $self->put(
	    uri => $uri,
	    form => $form,
	    query => $query,
	    query_string => $query_string,
	    task_id => $task_id,
	   );
    $self->internal_initialize($auth_realm, $auth_user);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="format_uri"></a>

=head2 format_uri(Bivio::Agent::TaskId task_id, string query, Bivio::Auth::Realm auth_realm) : string

=head2 format_uri(Bivio::Agent::TaskId task_id, hash_ref query, Bivio::Auth::Realm auth_realm) : string

Creates a URI relative to this host/port.
If I<query> is C<undef>, will not create a query string.
If I<auth_realm> is C<undef>, request's realm will be used.

=cut

#TODO: Removed this, maybe put back
#If I<query> is not passed, will use this request's query string.

sub format_uri {
    my($self, $task_id, $query, $auth_realm) = @_;
    # Note: Bivio::Agent::Mail::Request may call this.
    $task_id = $self->get_widget_value(@$task_id) if ref($task_id) eq 'ARRAY';
    $query = $self->get_widget_value(@$query) if ref($query) eq 'ARRAY';
    $auth_realm = $self->get_widget_value(@$auth_realm)
	    if ref($auth_realm) eq 'ARRAY';
    $task_id = $self->get('task_id') unless $task_id;
    # Allow the realm to be undef
    my($uri) = Bivio::Agent::HTTP::Location->format(
	    $task_id, int(@_) >= 4 ? $auth_realm : $self->get('auth_realm'));
#TODO: Is this right?
#    $query = $self->get('query_string') unless int(@_) >= 3;
    return $uri unless defined($query);
    return $uri.'?'.$query unless ref($query);
#TODO: Map query strings to brief names
    my(@s);
    while (my($k, $v) = each(%$query)) {
	next unless defined($v) && length($v);
	push(@s, $k . '=' . Bivio::Util::escape_uri($v));
    }
    return $uri . '?' . join('&', @s);
}

#=PRIVATE METHODS

# _auth_user(string name, string password) : Bivio::Biz::Model::User
#
# Attempts to find a user with the specified login id.
sub _auth_user {
    my($self, $name, $password) = @_;
    return undef unless defined($name);
    my($user) = Bivio::Biz::Model::RealmOwner->new($self);
#TODO: Do we want to allow club logins?
    Bivio::Die->die(Bivio::DieCode::AUTH_REQUIRED(),
	    {request => $self, entity => $name, message => 'user not found'})
	    unless $user->unauth_load(name => $name)
		    && defined($user->get('password'));
#TODO: set cookie for number of login attempts
    Bivio::Die->die(Bivio::DieCode::AUTH_REQUIRED(),
	    {request => $self, message => 'password mismatch',
		entity => $name, auth_user => $user})
    	    unless Bivio::Type::Password->is_equal($user->get('password'),
		    $password);
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
