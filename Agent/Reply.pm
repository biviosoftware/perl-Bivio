# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
$Bivio::Agent::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Agent::Reply - a user agent reply

=head1 SYNOPSIS

    my($req) = ...;
    my($reply) = $req->get_reply();

    $reply->set_output_type('image/gif');  # default is 'text/plain'
    $reply->print($image);
    $reply->set_state($reply->OK);
    $reply->flush();

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Reply::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Reply> is the complement to
L<Bivio::Agent::Request>, it is the output channel
for responses. Initially, a reply is in the NOT_HANDLED state indicating
that no action has been taken for the corresponding Request.

=cut

=head1 CONSTANTS

=cut

=for html <a name="OK"></a>

=head2 OK : int

successful

=cut

sub OK {
    return 0
}

=for html <a name="FORBIDDEN"></a>

=head2 FORBIDDEN : int

use not authorized to do request

=cut

sub FORBIDDEN {
    return 1;
}

=for html <a name="NOT_HANDLED"></a>

=head2 NOT_HANDLED : int

request not processed - ie not found

=cut

sub NOT_HANDLED {
    return 2;
}

=for html <a name="AUTH_REQUIRED"></a>

=head2 AUTH_REQUIRED : int

needs authorization to proceed

=cut

sub AUTH_REQUIRED {
    return 3;
}

=for html <a name="SERVER_ERROR"></a>

=head2 SERVER_ERROR : int

internal error

=cut

sub SERVER_ERROR {
    return 4;
}

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Reply

Creates a reply in the NOT_HANDLED state with the 'text/plain' output type.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
        'output_type' => 'text/plain',
        'state' => SERVER_ERROR,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="flush"></a>

=head2 abstract flush()

Sends the buffered reply data.

=cut

sub flush {
    die('abstract method');
}

=for html <a name="get_output_type"></a>

=head2 get_ouput_type() : string

Returns the reply format type.

=cut

sub get_output_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{output_type};
}

=for html <a name="get_state"></a>

=head2 get_state() : int

Returns the state of the request. This should be one of the constant
values described above.

=cut

sub get_state {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{state};
}

=for html <a name="print"></a>

=head2 abstract print(string str)

Writes the specified string to the request's output stream. Binary output
types can pass binary data to this method as well.

=cut

sub print {
    die("abstract method");
}

=for html <a name="set_output_type"></a>

=head2 set_output_type(string type)

Sets the reply format type. For example this could be 'text/html'.

=cut

sub set_output_type {
    my($self, $type) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{output_type} = $type;
    return;
}

=for html <a name="set_state"></a>

=head2 set_state(int state)

Sets the state of the request the specified value. This should be one of the
constant values describe above.

=cut

sub set_state {
    my($self, $state) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{state} = $state;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
