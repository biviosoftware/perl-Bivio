# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Reply;
use strict;
$Bivio::Agent::HTTP::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::HTTP::Reply - a HTTP reply

=head1 EXTENDS

L<Bivio::Agent::Reply>

=cut

use Bivio::Agent::Reply;
@Bivio::Agent::HTTP::Reply::ISA = qw(Bivio::Agent::Reply);

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Reply> is the complement to
L<Bivio::Agent::HTTP::Request|"Bivio::Agent::HTTPRequest">. By default the
output type will be 'text/html'.

=cut

#=IMPORTS
use Apache::Constants;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Apache::Request r) : Bivio::Agent::HTTP::Reply

Creates a new Reply type which uses the specified Apache::Request for
output operations.

=cut

sub new {
    my($proto, $r) = @_;
    my($self) = &Bivio::Agent::Reply::new($proto);
    $self->{$_PACKAGE} = {
        'header_sent' => 0,
	'r' => $r
    };
    # default output to html
    $self->set_output_type('text/html');

    return $self;
}

=head1 METHODS

=cut

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
	    if $state == $self->AUTH_REQUIRED;
    return Apache::Constants::FORBIDDEN
	    if $state == $self->FORBIDDEN;
    return Apache::Constants::NOT_FOUND
	    if $state == $self->NOT_HANDLED;
    return Apache::Constants::OK
	    if $state == $self->OK;
    return Apache::Constants::SERVER_ERROR
	    if $state == $self->SERVER_ERROR;

    die("invalid request state $state");
}

=for html <a name="print"></a>

=head2 print(string str)

Writes the specified string to the request's output stream.

=cut

sub print {
    my($self,$str) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{header_sent} == 0) {
	# only do this on first print
	$fields->{header_sent} = 1;

	$fields->{r}->content_type($self->get_output_type());
	$fields->{r}->send_http_header;
    }
    $fields->{r}->print(defined($str) ? $str : 'undef');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
