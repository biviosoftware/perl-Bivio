# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Request;
use strict;
use Apache::Constants;
use Bivio::Agent::Request();
$Bivio::Agent::HTTP::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::Request -  An HTTP Request

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Request;
    Bivio::Agent::HTTP::Request->new();

=cut

=head1 EXTENDS

L<Bivio::Agent::Request> is a Bivio Request wrapper for an Apache::Request.

=cut

@Bivio::Agent::HTTP::Request::ISA = qw(Bivio::Agent::Request);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Request>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Request

Creates a Request.

=cut

sub new {
    my($proto, $r) = @_;

    #this is required for the connection->user to work!?
    $r->get_basic_auth_pw();
    my($user) = $r->connection->user;
    my($target, $controller, $path) = _parse_request($r->uri());

    my($self) = &Bivio::Agent::Request::new($proto, $target, $controller,
	   $user);
    $self->{$PACKAGE} = {
        r => $r,
	path => $path,
        header_send => 0
    };

    #default to html
    $self->set_reply_type('text/html');

    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_arg"></a>

=head2 get_arg(string name) : string

Returns the named request argument value from the inquiry or posted
parameters. If the argument doesn't exist, '' is returned.

=cut

sub get_arg {
    my($self,$name) = @_;
    my($fields) = $self->{$PACKAGE};

    my(%args) = $fields->{'r'}->args;
    return $args{$name} || '';
}

=for html <a name="get_http_return_code"></a>

=head2 get_http_return_code() : int

Returns the appropriate Apache::Constant depending on the current state
of the request.

=cut

sub get_http_return_code {
    my($self) = @_;
    my($state) = $self->get_state();

    # need to translate from Request state to Apache rc
    return Apache::Constants::AUTH_REQUIRED
	    if $state == Bivio::Agent::Request::AUTH_REQUIRED;
    return Apache::Constants::FORBIDDEN
	    if $state == Bivio::Agent::Request::FORBIDDEN;
    return Apache::Constants::NOT_FOUND
	    if $state == Bivio::Agent::Request::NOT_HANDLED;
    return Apache::Constants::OK
	    if $state == Bivio::Agent::Request::OK;
    return Apache::Constants::SERVER_ERROR
	    if $state == Bivio::Agent::Request::SERVER_ERROR;

    #otherwise, an invalid state was set, log it and die
    $self->log_error("invalid request state $state");
    die("invalid request state $state");
}

=for html <a name="get_path"></a>

=head2 get_path() : array

Returns the full path of the request.

=cut

sub get_path {
    my($self) = @_;
    my($fields) = $self->{$PACKAGE};
    return $fields->{path};
}

=for html <a name="log_error"></a>

=head2 log_error(string message)

Writes the specified message to an error log appropriate for the request.

=cut

sub log_error {
    my($self, $message) = @_;
    my($fields) = $self->{$PACKAGE};
    $fields->{'r'}->log_error($message);
}

=for html <a name="print"></a>

=head2 print(string str)

Writes the specified string to the request's output stream.

=cut

sub print {
    my($self,$str) = @_;
    my($fields) = $self->{$PACKAGE};

    if ($fields->{'header_sent'} == 0) {
	# only do this on first print
	$fields->{'header_sent'} = 1;

	$fields->{'r'}->content_type($self->get_reply_type());
	$fields->{'r'}->send_http_header;
    }
    $fields->{'r'}->print($str);
}

=for html <a name="put_arg"></a>

=head2 put_arg(string name, string value)

Adds or updates the argument to the specified value.

=cut

sub put_arg {
    my($self, $name, $value) = @_;
    my($fields) = $self->{$PACKAGE};

    my(%args);
    %args = $self->{'r'}->args;
    $args{$name} = $value;
}

#=PRIVATE METHODS

# _parse_request(string uri) : (string, string, array)
#
# Takes a URI request and parses the target, controller, and path.
#
# input format: /<target>[/<controller>[/<path][/]]
#
sub _parse_request {
    my($str) = @_;

    # trim leading and trailing '/'
    $str =~ s|^/(.+)$|$1|;
    $str =~ s|^(.+)/$|$1|;

    my(@parts) = split('/', $str);

    my($target) = $parts[0];
    my($controller) = $parts[1] || '';
    my(@path) = @parts[0..$#parts];

    return ($target, $controller, \@path);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

=head1 x

sub t {
    my($target, $controller, $path) = @_;
    print("target = $target\ncontroller = $controller\n");
    my($p);
    foreach $p (@$path) {
	print($p.'/');
    }
    print("\n");
}

t(_parse_request("/localhost"));

=cut

1;
