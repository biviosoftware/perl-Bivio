# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::Reply;
use strict;
$Bivio::Agent::Reply::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::Reply::VERSION;

=head1 NAME

Bivio::Agent::Reply - a user agent reply

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

   use Bivio::Agent::Reply;

=cut

use Bivio::Collection::Attributes;
@Bivio::Agent::Reply::ISA = qw(Bivio::Collection::Attributes);

=head1 DESCRIPTION

C<Bivio::Agent::Reply> is the complement to
L<Bivio::Agent::Request>, it is the output channel.

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Agent::Reply

Creates a reply in an error state with the 'text/plain' output type.

=cut

sub new {
    return shift->SUPER::new({
        output_type => 'text/plain',
    });
}

=head1 METHODS

=cut

=for html <a name="get_output_type"></a>

=head2 get_ouput_type() : string

Returns the reply format type.

=cut

sub get_output_type {
    return shift->get('output_type');
}

=for html <a name="send"></a>

=head2 send(Bivio::Agent::Request req)

Sends the buffered reply data.

=cut

sub send {
    return;
}

=for html <a name="set_header"></a>

=head2 set_header(string name, string value) : self

Sets an arbitrary header value.

=cut

sub set_header {
    my($self, $name, $value) = @_;
    $self->get_if_exists_else_put('headers', {})->{$name} = $value;
    return $self;
}

=for html <a name="set_output"></a>

=head2 set_output(scalar_ref value) : self

=head2 set_output(io_handle file) : self

Sets the output to the file.  Output type must be set.
I<file> or I<value> will be owned by this method.

=cut

sub set_output {
    return shift->put(output => shift);
}

=for html <a name="set_output_type"></a>

=head2 set_output_type(string type) : self

Sets the reply format type. For example this could be 'text/html'.

=cut

sub set_output_type {
    return shift->put(output_type => shift);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
