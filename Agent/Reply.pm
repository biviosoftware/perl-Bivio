# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
$Bivio::Agent::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);
$_ = $Bivio::Agent::Reply::VERSION;

=head1 NAME

Bivio::Agent::Reply - a user agent reply

=head1 SYNOPSIS

    my($req) = ...;
    my($reply) = $req->get('reply');

    $reply->set_output_type('image/gif');  # default is 'text/plain'
    $reply->set_output(\$image);
    $reply->send($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Reply::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Reply> is the complement to
L<Bivio::Agent::Request>, it is the output channel.

=cut

#=IMPORTS
use Bivio::DieCode;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Reply

Creates a reply in an error state with the 'text/plain' output type.

=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
        'output_type' => 'text/plain',
        'die_code' => Bivio::DieCode::DIE(),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_output_type"></a>

=head2 get_ouput_type() : string

Returns the reply format type.

=cut

sub get_output_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{output_type};
}

=for html <a name="send"></a>

=head2 send(Bivio::Agent::Request req)

Sends the buffered reply data.

=cut

sub send {
}

=for html <a name="set_output"></a>

=head2 set_output(scalar_ref value)

=head2 set_output(io_handle file)

Sets the output to the file.  Output type must be set.
I<file> or I<value> will be owned by this method.

=cut

sub set_output {
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
